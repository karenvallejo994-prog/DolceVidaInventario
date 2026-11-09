package com.dolcevida.control;

import com.dolcevida.model.Producto;
import com.dolcevida.util.HibernateUtil;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.hibernate.Session;

@WebServlet(name = "ProductoController", urlPatterns = {"/ProductoController"})
public class ProductoController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Session hibernateSession = null;
        try {
            // 1. Abrimos el túnel de conexión con HibernateUtil
            hibernateSession = HibernateUtil.getSessionFactory().openSession();
            
            // 2. Hacemos una consulta HQL para traer todos los productos de MySQL
            List<Producto> listaProductos = hibernateSession.createQuery("FROM Producto", Producto.class).list();
            
            // 3. Enviamos la lista de dulces a la capa de presentación (la página jsp)
            request.setAttribute("productos", listaProductos);
            request.getRequestDispatcher("productos.jsp").forward(request, response);
            
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Error al consultar el inventario: " + e.getMessage());
        } finally {
            if (hibernateSession != null && hibernateSession.isOpen()) {
                // 4. Siempre cerramos la sesión por seguridad
                hibernateSession.close();
            }
        }
    }
}
