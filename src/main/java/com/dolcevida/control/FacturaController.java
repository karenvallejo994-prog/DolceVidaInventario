package com.dolcevida.control;

import com.dolcevida.model.DetalleFactura;
import com.dolcevida.model.Factura;
import com.dolcevida.model.Producto;
import com.dolcevida.model.Usuario;
import com.dolcevida.util.HibernateUtil;
import java.io.IOException;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.hibernate.Session;
import org.hibernate.Transaction;

@WebServlet(name = "FacturaController", urlPatterns = {"/FacturaController"})
public class FacturaController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        int idProducto = Integer.parseInt(request.getParameter("idProducto"));
        int cantidadVenta = Integer.parseInt(request.getParameter("cantidad"));
        
        HttpSession session = request.getSession();
        String nombreUsuarioLogueado = (String) session.getAttribute("usuarioLogueado");

        Session hibernateSession = null;
        Transaction tx = null;
        
        try {
            hibernateSession = HibernateUtil.getSessionFactory().openSession();
            tx = hibernateSession.beginTransaction();
            
            Producto producto = hibernateSession.get(Producto.class, idProducto);
            Usuario usuario = (Usuario) hibernateSession.createQuery("FROM Usuario WHERE usuario = :user")
                    .setParameter("user", nombreUsuarioLogueado).uniqueResult();
            
            if (producto != null && usuario != null) {
                int stockActual = producto.getCantidad();
                
                // Validamos que haya suficiente stock en la tienda para efectuar la venta
                if (cantidadVenta > stockActual) {
                    tx.rollback();
                    response.getWriter().println("<script>alert('Error: Stock insuficiente para realizar la venta.'); window.location.href='facturacion.jsp';</script>");
                    return;
                }
                
                // 1. Restamos la cantidad vendida al stock del producto
                producto.setCantidad(stockActual - cantidadVenta);
                hibernateSession.update(producto);
                
                // 2. Calculamos los valores de la factura
                double subtotalCalculado = producto.getPrecio() * cantidadVenta;
                
                // 3. Guardamos el encabezado de la Factura
                Factura factura = new Factura();
                factura.setUsuario(usuario);
                factura.setFecha(new Date());
                factura.setTotal(subtotalCalculado);
                hibernateSession.save(factura);
                
                // 4. Guardamos el renglón en Detalle Factura
                DetalleFactura detalle = new DetalleFactura();
                detalle.setFactura(factura);
                detalle.setProducto(producto);
                detalle.setCantidad(cantidadVenta);
                detalle.setPrecioUnitario(producto.getPrecio());
                hibernateSession.save(detalle);
                
                tx.commit();
                
                // Redirigimos al catálogo para comprobar que el stock disminuyó de inmediato
                response.sendRedirect("ProductoController");
            } else {
                if (tx != null) tx.rollback();
                response.getWriter().println("Error: Producto o Usuario no válido.");
            }
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            response.getWriter().println("Error crítico en la facturación: " + e.getMessage());
        } finally {
            if (hibernateSession != null && hibernateSession.isOpen()) {
                hibernateSession.close();
            }
        }
    }
}
