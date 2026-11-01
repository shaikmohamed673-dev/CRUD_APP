<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Employee Form</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 24px; max-width: 480px; }
    label { display: block; margin-top: 12px; }
    input { width: 100%; padding: 8px; box-sizing: border-box; }
    button, a { margin-top: 16px; padding: 8px 14px; }
  </style>
</head>
<body>
  <h1><c:out value="${employee.id == 0 ? 'Add' : 'Edit'}"/> Employee</h1>
  <form method="post" action="employees">
    <input type="hidden" name="id" value="${employee.id == 0 ? '' : employee.id}"/>
    <label>Name
      <input type="text" name="name" value="<c:out value='${employee.name}'/>" required/>
    </label>
    <label>Email
      <input type="email" name="email" value="<c:out value='${employee.email}'/>" required/>
    </label>
    <label>Department
      <input type="text" name="department" value="<c:out value='${employee.department}'/>"/>
    </label>
    <button type="submit">Save</button>
    <a href="employees">Cancel</a>
  </form>
</body>
</html>