CREATE TABLE IF NOT EXISTS employees (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(150) NOT NULL UNIQUE,
    department  VARCHAR(100)
);

INSERT INTO employees (name, email, department) VALUES
  ('Asha Rao', 'asha@example.com', 'Engineering'),
  ('Ravi Kumar', 'ravi@example.com', 'Operations')
ON CONFLICT DO NOTHING;