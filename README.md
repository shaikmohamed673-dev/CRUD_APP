# Employee CRUD App

A Java Servlet/JSP employee management app packaged as a WAR and backed by PostgreSQL. It supports listing, creating, editing, and deleting employees.

## Project files

- `src/main/java/com/example/crud/model/Employee.java` - Employee data model.
- `src/main/java/com/example/crud/dao/EmployeeDao.java` - PostgreSQL queries and connection configuration.
- `src/main/java/com/example/crud/web/EmployeeServlet.java` - Handles employee requests at `/employees`.
- `src/main/webapp/WEB-INF/views/` - JSP pages for the employee list and form.
- `src/main/webapp/WEB-INF/web.xml` - Web application descriptor and welcome page.
- `db/schema.sql` - Creates the employees table and inserts sample rows.
- `deploy/deploy.sh` - Builds and deploys the WAR to `/opt/tomcat`.
- `deploy/nginx-crud.conf` - Nginx reverse-proxy configuration.

## Requirements

- Java 17
- Maven
- PostgreSQL
- Apache Tomcat 9 (Servlet 4 / `javax.servlet`)
- Optional for a public HTTP endpoint: Nginx and an Azure inbound TCP port 80 rule

Tomcat 10+ uses Jakarta Servlet packages and is not compatible with this project's `javax.servlet` dependencies without code changes.

## 1. Get the project

Clone the repository and enter its directory:

```sh
git clone https://github.com/shaikmohamed673-dev/CRUD_APP.git
cd CRUD_APP
```

Run all Maven and database commands below from this project directory.

## 2. Create and configure the PostgreSQL database

The application expects a PostgreSQL database named `cruddb` and a login role named `cruduser`. If they do not already exist, create them as a PostgreSQL administrator:

```sh
sudo -u postgres psql
```

At the PostgreSQL prompt:

```sql
CREATE ROLE cruduser LOGIN;
\password cruduser
CREATE DATABASE cruddb OWNER cruduser;
\q
```

If the role or database already exists, do not create it again. Set or reset the role password with `\password cruduser`, and confirm that the role has access to `cruddb`.

Apply the schema from the project directory. `-W` asks for the database password interactively:

```sh
psql -h 127.0.0.1 -U cruduser -d cruddb -W -f db/schema.sql
```

The script creates the `employees` table and inserts two sample employees. The email column is unique; use a different email for each employee. Re-running the schema does not duplicate its sample rows.

## 3. Configure database access for Tomcat

The application reads these environment variables:

- `DB_URL` - JDBC URL; default is `jdbc:postgresql://localhost:5432/cruddb`.
- `DB_USER` - PostgreSQL role; default is `cruduser`.
- `DB_PASSWORD` - Password for that role.

The source code includes a development fallback password (`ChangeMe123`). Do not use that fallback on a server. Set the real database password for the Tomcat service, and never commit passwords to Git or paste them into shared logs.

On a systemd-based Linux server, create a root-owned environment file:

```sh
sudo install -o root -g root -m 600 /dev/null /etc/tomcat/crud-app.env
sudo nano /etc/tomcat/crud-app.env
```

Put these lines in the file, replacing the password placeholder with the password set for PostgreSQL role `cruduser`:

```text
DB_URL=jdbc:postgresql://localhost:5432/cruddb
DB_USER=cruduser
DB_PASSWORD=replace_with_the_real_database_password
```

Save and exit the editor. Configure the Tomcat systemd service to load this file:

```sh
sudo systemctl edit tomcat
```

Add the following override in the blank section at the top of the editor:

```ini
[Service]
EnvironmentFile=/etc/tomcat/crud-app.env
```

Save and exit. Do not edit the commented original service definition below the divider. Then reload systemd and restart Tomcat:

```sh
sudo systemctl daemon-reload
sudo systemctl restart tomcat
sudo systemctl status tomcat --no-pager
```

Check that systemd has registered the environment file without printing its secret contents:

```sh
sudo systemctl show tomcat -p EnvironmentFiles
```

The output should include `/etc/tomcat/crud-app.env`. To verify the PostgreSQL password independently, run `psql -h 127.0.0.1 -U cruduser -d cruddb -W` and enter the password at the prompt.

## 4. Build the WAR

From the project directory:

```sh
mvn clean package
```

A successful build creates `target/ROOT.war`. Confirm it exists before deploying:

```sh
test -f target/ROOT.war && ls -lh target/ROOT.war
```

## 5. Deploy to Tomcat

For the included deployment script, ensure Tomcat is installed at `/opt/tomcat` and its systemd service is named `tomcat`. Then run:

```sh
bash deploy/deploy.sh
```

The script builds the project and replaces `/opt/tomcat/webapps/ROOT` and `/opt/tomcat/webapps/ROOT.war`. Back up any existing ROOT application before running it if you need to keep that application. Alternatively, deploy manually:

```sh
sudo systemctl stop tomcat
sudo cp target/ROOT.war /opt/tomcat/webapps/ROOT.war
sudo chown tomcat:tomcat /opt/tomcat/webapps/ROOT.war
sudo systemctl start tomcat
```

Tomcat deploys the WAR as the ROOT web application, so the employee list is at `/employees`.

Test from the Linux server:

```sh
curl -i http://127.0.0.1:8080/employees
```

An `HTTP/1.1 200` response with the employee list indicates the app is responding. This check is local to the server; it does not prove that the port is reachable from the internet.

## 6. Optional: expose the app through Nginx

Use Nginx as a reverse proxy so browsers use HTTP port 80 while Tomcat port 8080 remains private. On Ubuntu/Debian:

```sh
sudo apt update
sudo apt install nginx
sudo cp deploy/nginx-crud.conf /etc/nginx/sites-available/crud-app
sudo ln -s /etc/nginx/sites-available/crud-app /etc/nginx/sites-enabled/crud-app
```

If the `crud-app` link already exists, do not create a duplicate. If Nginx's default site intercepts the request, disable that default site after confirming it is not needed. Validate and start/reload Nginx:

```sh
sudo nginx -t
sudo systemctl enable --now nginx
sudo systemctl reload nginx
curl -i http://127.0.0.1/employees
```

The local Nginx request should return `HTTP/1.1 200`. The provided configuration proxies requests to `127.0.0.1:8080`.

## 7. Allow browser access on Azure

For a public HTTP site:

1. In the Azure Portal, open the VM's **Networking** settings and add an inbound **TCP 80** allow rule. Restrict the source to your IP if the site should not be public.
2. If UFW is enabled, allow HTTP on the server:
   ```sh
   sudo ufw allow 80/tcp
   ```
3. Open `http://<your-server-public-IP>/employees` in a browser.

Do not open port 8080 to the public when using Nginx. Use `http://<server-ip>:8080/employees` only for direct access when you have deliberately configured both Azure networking and the server firewall to permit that port.

## Troubleshooting

- **HTTP 500: password authentication failed** - Confirm `psql -h 127.0.0.1 -U cruduser -d cruddb -W` accepts the password. Ensure the Tomcat environment file has the same password and that `systemctl show tomcat -p EnvironmentFiles` lists that file. Restart Tomcat after configuration changes. Never share the environment file contents.
- **HTTP 500: duplicate key value violates unique constraint `employees_email_key`** - That email is already in use. Choose another email or edit the existing employee.
- **Connection refused on port 8080** - Check `sudo systemctl status tomcat --no-pager` and confirm Tomcat is listening with `sudo ss -ltnp | grep ':8080'`. A restart may take a few seconds; retry after it is active.
- **Browser times out but server-local curl succeeds** - Check Nginx and Azure inbound TCP port 80 rules. If connecting directly to Tomcat, check port 8080 rules as well.
- **Nginx returns an error** - Run `sudo nginx -t`, then inspect `sudo journalctl -u nginx -n 40 --no-pager`.
- **Tomcat deployment errors** - Inspect `sudo journalctl -u tomcat -n 60 --no-pager` and Tomcat's logs under `/opt/tomcat/logs/`.

## Employee operations

Open `/employees` to list records. Use **Add Employee** to create a record, **Edit** to update one, or **Delete** to remove one. Employee email addresses must be unique.