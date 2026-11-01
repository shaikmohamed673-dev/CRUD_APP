# Employee CRUD App

A Java Servlet/JSP employee management app packaged as a WAR and backed by PostgreSQL.

## Requirements

- Java 17
- Maven
- PostgreSQL
- Apache Tomcat 9 (Servlet 4 / `javax.servlet`)

## Database setup

Create a PostgreSQL database and user, then apply the schema:

```sh
psql -d cruddb -f db/schema.sql
```

The application defaults to `jdbc:postgresql://localhost:5432/cruddb`, user `cruduser`, and password `ChangeMe123`. Override these with `DB_URL`, `DB_USER`, and `DB_PASSWORD` environment variables before starting Tomcat.

## Build and deploy

```sh
mvn clean package
```

This creates `target/ROOT.war`. Copy it to Tomcat's `webapps` directory, start Tomcat, and visit `/employees`. The deployment script in `deploy/deploy.sh` builds and deploys to `/opt/tomcat`; adjust `TOMCAT_HOME` for your installation.

The optional Nginx server configuration is in `deploy/nginx-crud.conf`.