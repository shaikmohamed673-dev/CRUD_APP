<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Employees</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 24px; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
    th { background: #f0f0f0; }
    a.btn { padding: 6px 10px; background: #2563eb; color: #fff; text-decoration: none; border-radius: 4px; }
    a.del { background: #dc2626; }
  </style>
</head>
<body>
  <h1>Employees</h1>
  <p><a class="btn" href="employees?action=new">+ Add Employee</a></p>
  <table>
    <tr><th>ID</th><th>Name</th><th>Email</th><th>Department</th><th>Actions</th></tr>
    <c:forEach var="e" items="${employees}">
      <tr>
        <td><c:out value="${e.id}"/></td>
        <td><c:out value="${e.name}"/></td>
        <td><c:out value="${e.email}"/></td>
        <td><c:out value="${e.department}"/></td>
        <td>
          <a class="btn" href="employees?action=edit&id=${e.id}">Edit</a>
          <a class="btn del" href="employees?action=delete&id=${e.id}"
             onclick="return confirm('Delete this employee?');">Delete</a>
        </td>
      </tr>
    </c:forEach>
  </table>
</body>
</html>