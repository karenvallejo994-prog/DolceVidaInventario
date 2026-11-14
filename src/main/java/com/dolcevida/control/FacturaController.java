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
        
        response.setContentType("text/html;charset=UTF-8");
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("usuarioLogueado") == null) {
            response.sendRedirect("index.html");
            return;
        }

        String[] idsProductos = request.getParameterValues("idProducto");
        String[] cantidades = request.getParameterValues("cantidad");
        
        if (idsProductos == null || cantidades == null || idsProductos.length == 0) {
            response.getWriter().println("<script>alert('Error: No se seleccionaron productos para facturar.'); window.location.href='facturacion.jsp';</script>");
            return;
        }

        String nombreUsuarioLogueado = (String) session.getAttribute("usuarioLogueado");

        Session hibernateSession = null;
        Transaction tx = null;
        
        try {
            hibernateSession = HibernateUtil.getSessionFactory().openSession();
            tx = hibernateSession.beginTransaction();
            
            Usuario usuario = (Usuario) hibernateSession.createQuery("FROM Usuario WHERE usuario = :user")
                    .setParameter("user", nombreUsuarioLogueado).uniqueResult();
            
            if (usuario == null) {
                tx.rollback();
                response.getWriter().println("<script>alert('Error: Usuario de sesión no válido.'); window.location.href='index.html';</script>");
                return;
            }

            // 1. Creamos el encabezado de la Factura principal
            Factura factura = new Factura();
            factura.setUsuario(usuario);
            factura.setFecha(new Date());
            factura.setTotal(0.0);
            hibernateSession.save(factura);

            double totalFactura = 0.0;

            // 2. Recorremos todos los productos agregados al carrito
            for (int i = 0; i < idsProductos.length; i++) {
                int idProd = Integer.parseInt(idsProductos[i]);
                int cantVenta = Integer.parseInt(cantidades[i]);

                Producto producto = hibernateSession.get(Producto.class, idProd);
                if (producto == null) {
                    tx.rollback();
                    response.getWriter().println("<script>alert('Error: Uno de los productos no existe en la base de datos.'); window.location.href='facturacion.jsp';</script>");
                    return;
                }

                int stockActual = producto.getCantidad();
                if (cantVenta > stockActual) {
                    tx.rollback();
                    response.getWriter().println("<script>alert('Error: Stock insuficiente para " + producto.getNombre() + " (Disponible: " + stockActual + ").'); window.location.href='facturacion.jsp';</script>");
                    return;
                }

                // Descontamos stock en inventario
                producto.setCantidad(stockActual - cantVenta);
                hibernateSession.update(producto);

                // Calculamos subtotal y sumamos al total general
                double subtotalItem = producto.getPrecio() * cantVenta;
                totalFactura += subtotalItem;

                // Guardamos cada línea en DetalleFactura
                DetalleFactura detalle = new DetalleFactura();
                detalle.setFactura(factura);
                detalle.setProducto(producto);
                detalle.setCantidad(cantVenta);
                detalle.setPrecioUnitario(producto.getPrecio());
                hibernateSession.save(detalle);
            }

            // 3. Actualizamos el total definitivo en el encabezado de la factura
            factura.setTotal(totalFactura);
            hibernateSession.update(factura);
            
            tx.commit();
            
            response.getWriter().println("<script>"
                    + "alert('¡Venta registrada con éxito! Total facturado: $" + String.format("%,.0f", totalFactura) + "');"
                    + "window.location.href='ProductoController';"
                    + "</script>");
            
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
