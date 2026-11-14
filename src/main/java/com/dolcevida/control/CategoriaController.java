package com.dolcevida.control;

import com.dolcevida.model.Categoria;
import com.dolcevida.util.HibernateUtil;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.hibernate.Session;
import org.hibernate.Transaction;

@WebServlet(name = "CategoriaController", urlPatterns = {"/CategoriaController"})
public class CategoriaController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String accion = request.getParameter("accion");
        if ("eliminar".equals(accion)) {
            int idEliminar = Integer.parseInt(request.getParameter("id"));
            Session hibernateSession = null;
            Transaction tx = null;
            try {
                hibernateSession = HibernateUtil.getSessionFactory().openSession();
                tx = hibernateSession.beginTransaction();
                Categoria cat = hibernateSession.get(Categoria.class, idEliminar);
                if (cat != null) {
                    try {
                        hibernateSession.delete(cat);
                        tx.commit();
                        response.getWriter().println("<script>alert('Categoría eliminada correctamente.'); window.location.href='categorias.jsp';</script>");
                    } catch (Exception ex) {
                        if (tx != null) tx.rollback();
                        response.getWriter().println("<script>alert('No se puede eliminar esta categoría porque tiene productos registrados. Cambia o elimina primero sus productos.'); window.location.href='categorias.jsp';</script>");
                    }
                }
            } catch (Exception e) {
                if (tx != null) tx.rollback();
                e.printStackTrace();
            } finally {
                if (hibernateSession != null && hibernateSession.isOpen()) {
                    hibernateSession.close();
                }
            }
        } else {
            response.sendRedirect("categorias.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String accion = request.getParameter("accion");
        String nombre = request.getParameter("nombreCategoria");
        String descripcion = request.getParameter("descripcion");

        Session hibernateSession = null;
        Transaction tx = null;

        try {
            hibernateSession = HibernateUtil.getSessionFactory().openSession();
            tx = hibernateSession.beginTransaction();

            if ("crear".equals(accion)) {
                Categoria nueva = new Categoria();
                nueva.setNombreCategoria(nombre);
                nueva.setDescripcion(descripcion);
                hibernateSession.save(nueva);
                tx.commit();
                response.getWriter().println("<script>alert('¡Nueva categoría creada con éxito! 📁'); window.location.href='categorias.jsp';</script>");

            } else if ("editar".equals(accion)) {
                int idCat = Integer.parseInt(request.getParameter("idCategoria"));
                Categoria existente = hibernateSession.get(Categoria.class, idCat);
                if (existente != null) {
                    existente.setNombreCategoria(nombre);
                    existente.setDescripcion(descripcion);
                    hibernateSession.update(existente);
                    tx.commit();
                }
                response.getWriter().println("<script>alert('¡Categoría actualizada correctamente! ✨'); window.location.href='categorias.jsp';</script>");
            }

        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            response.getWriter().println("Error al procesar categoría: " + e.getMessage());
        } finally {
            if (hibernateSession != null && hibernateSession.isOpen()) {
                hibernateSession.close();
            }
        }
    }
}

