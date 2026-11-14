package com.dolcevida.control;

import com.dolcevida.model.Categoria;
import com.dolcevida.model.Producto;
import com.dolcevida.util.HibernateUtil;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.hibernate.Session;
import org.hibernate.Transaction;

@WebServlet(name = "ProductoController", urlPatterns = {"/ProductoController"})
public class ProductoController extends HttpServlet {

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
        Session hibernateSession = null;
        Transaction tx = null;

        try {
            hibernateSession = HibernateUtil.getSessionFactory().openSession();

            // ACCIÓN ELIMINAR PRODUCTO
            if ("eliminar".equals(accion)) {
                int idEliminar = Integer.parseInt(request.getParameter("id"));
                tx = hibernateSession.beginTransaction();
                Producto prodEliminar = hibernateSession.get(Producto.class, idEliminar);
                if (prodEliminar != null) {
                    try {
                        hibernateSession.delete(prodEliminar);
                        tx.commit();
                        response.getWriter().println("<script>alert('Producto eliminado correctamente.'); window.location.href='ProductoController';</script>");
                    } catch (Exception ex) {
                        if (tx != null) tx.rollback();
                        response.getWriter().println("<script>alert('No se puede eliminar este producto porque ya tiene facturas registradas. Puedes editar su stock a 0.'); window.location.href='ProductoController';</script>");
                    }
                    return;
                }
            }

            // LISTAR PRODUCTOS Y CATEGORÍAS PARA LA VISTA
            List<Producto> listaProductos = hibernateSession.createQuery("FROM Producto", Producto.class).list();
            List<Categoria> listaCategorias = hibernateSession.createQuery("FROM Categoria", Categoria.class).list();

            request.setAttribute("productos", listaProductos);
            request.setAttribute("categorias", listaCategorias);
            request.getRequestDispatcher("productos.jsp").forward(request, response);
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            response.getWriter().println("Error en el módulo de inventario: " + e.getMessage());
        } finally {
            if (hibernateSession != null && hibernateSession.isOpen()) {
                hibernateSession.close();
            }
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
        String nombre = request.getParameter("nombre");
        int idCategoria = Integer.parseInt(request.getParameter("idCategoria"));
        int cantidad = Integer.parseInt(request.getParameter("cantidad"));
        double precio = Double.parseDouble(request.getParameter("precio"));
        String fechaVencStr = request.getParameter("fechaVencimiento");

        Session hibernateSession = null;
        Transaction tx = null;

        try {
            hibernateSession = HibernateUtil.getSessionFactory().openSession();
            tx = hibernateSession.beginTransaction();

            Categoria categoria = hibernateSession.get(Categoria.class, idCategoria);
            Date fechaVenc = null;
            if (fechaVencStr != null && !fechaVencStr.trim().isEmpty()) {
                fechaVenc = new SimpleDateFormat("yyyy-MM-dd").parse(fechaVencStr);
            }

            if ("crear".equals(accion)) {
                Producto nuevo = new Producto();
                nuevo.setNombre(nombre);
                nuevo.setCategoria(categoria);
                nuevo.setCantidad(cantidad);
                nuevo.setPrecio(precio);
                nuevo.setFechaVencimiento(fechaVenc);
                nuevo.setFechaRegistro(new Date());
                hibernateSession.save(nuevo);
                tx.commit();

                response.getWriter().println("<script>alert('¡Producto nuevo registrado exitosamente! 🍬'); window.location.href='ProductoController';</script>");

            } else if ("editar".equals(accion)) {
                int idProducto = Integer.parseInt(request.getParameter("idProducto"));
                Producto existente = hibernateSession.get(Producto.class, idProducto);
                if (existente != null) {
                    existente.setNombre(nombre);
                    existente.setCategoria(categoria);
                    existente.setCantidad(cantidad);
                    existente.setPrecio(precio);
                    existente.setFechaVencimiento(fechaVenc);
                    hibernateSession.update(existente);
                    tx.commit();
                }
                response.getWriter().println("<script>alert('¡Producto actualizado correctamente! ✨'); window.location.href='ProductoController';</script>");
            }

        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            response.getWriter().println("Error al guardar producto: " + e.getMessage());
        } finally {
            if (hibernateSession != null && hibernateSession.isOpen()) {
                hibernateSession.close();
            }
        }
    }
}
