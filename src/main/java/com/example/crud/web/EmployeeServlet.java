package com.example.crud.web;

import com.example.crud.dao.EmployeeDao;
import com.example.crud.model.Employee;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/employees")
public class EmployeeServlet extends HttpServlet {
    private final EmployeeDao dao = new EmployeeDao();
    private static final String VIEWS = "/WEB-INF/views/";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "list";
        try {
            switch (action) {
                case "new":
                    req.setAttribute("employee", new Employee());
                    req.getRequestDispatcher(VIEWS + "form.jsp").forward(req, resp);
                    break;
                case "edit":
                    int id = Integer.parseInt(req.getParameter("id"));
                    req.setAttribute("employee", dao.findById(id));
                    req.getRequestDispatcher(VIEWS + "form.jsp").forward(req, resp);
                    break;
                case "delete":
                    dao.delete(Integer.parseInt(req.getParameter("id")));
                    resp.sendRedirect(req.getContextPath() + "/employees");
                    break;
                default:
                    req.setAttribute("employees", dao.findAll());
                    req.getRequestDispatcher(VIEWS + "list.jsp").forward(req, resp);
            }
        } catch (SQLException | NumberFormatException ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Employee e = new Employee();
        e.setName(req.getParameter("name"));
        e.setEmail(req.getParameter("email"));
        e.setDepartment(req.getParameter("department"));
        String idParam = req.getParameter("id");
        try {
            if (idParam == null || idParam.isEmpty()) {
                dao.insert(e);
            } else {
                e.setId(Integer.parseInt(idParam));
                dao.update(e);
            }
        } catch (SQLException | NumberFormatException ex) {
            throw new ServletException(ex);
        }
        resp.sendRedirect(req.getContextPath() + "/employees");
    }
}