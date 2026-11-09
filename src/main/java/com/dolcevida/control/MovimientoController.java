package com.dolcevida.control;

import com.dolcevida.model.MovimientoInventario;
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

@WebServlet(name = "MovimientoController", urlPatterns = {"/MovimientoController"})
public class MovimientoController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Recupera los datos enviados desde el formulario movimientos.jsp
        int idProducto = Integer.parseInt(request.getParameter("idProducto"));
        String tipoMovimiento = request.getParameter("tipoMovimiento");
        int cantidadMovimiento = Integer.parseInt(request.getParameter("cantidad"));
        String observacion = request.getParameter("observacion");
        
        // Recupera el usuario que inició sesión
        HttpSession session = request.getSession();
        String nombreUsuarioLogueado = (String) session.getAttribute("usuarioLogueado");

        Session hibernateSession = null;
        Transaction tx = null;
        
        try {
            hibernateSession = HibernateUtil.getSessionFactory().openSession();
            tx = hibernateSession.beginTransaction();
            
            // 2. Buscamos el producto y el usuario en la base de datos usando Hibernate
            Producto producto = hibernateSession.get(Producto.class, idProducto);
            Usuario usuario = (Usuario) hibernateSession.createQuery("FROM Usuario WHERE usuario = :user")
                    .setParameter("user", nombreUsuarioLogueado).uniqueResult();
            
            if (producto != null && usuario != null) {
                // 3. Modificamos el stock del producto según el tipo de movimiento
                int stockActual = producto.getCantidad();
                
                if ("ENTRADA".equals(tipoMovimiento)) {
                    producto.setCantidad(stockActual + cantidadMovimiento);
                } else if ("SALIDA".equals(tipoMovimiento)) {
                    // Validamos que no se retire más de lo que hay en existencia
                    if (cantidadMovimiento > stockActual) {
                        tx.rollback();
                        response.getWriter().println("<script>alert('Error: No puedes retirar una cantidad mayor al stock disponible.'); window.location.href='movimientos.jsp';</script>");
                        return;
                    }
                    producto.setCantidad(stockActual - cantidadMovimiento);
                } else if ("AJUSTE".equals(tipoMovimiento)) {
                    producto.setCantidad(cantidadMovimiento); // En ajuste, la cantidad se vuelve el nuevo stock total
                }
                
                // Actualizamos el producto modificado en MySQL
                hibernateSession.update(producto);
                
                // 4. Guardamos el registro histórico en la tabla movimientos_inventario
                MovimientoInventario movimiento = new MovimientoInventario();
                movimiento.setProducto(producto);
                movimiento.setUsuario(usuario);
                movimiento.setTipoMovimiento(tipoMovimiento);
                movimiento.setCantidad(cantidadMovimiento);
                movimiento.setFechaMovimiento(new Date());
                movimiento.setObservacion(observacion);
                
                hibernateSession.save(movimiento);
                
                // Confirmamos la transacción completa en la base de datos
                tx.commit();
                
                // Redirigimos de vuelta al catálogo de productos para ver el cambio reflejado al instante
                response.sendRedirect("ProductoController");
            } else {
                if (tx != null) tx.rollback();
                response.getWriter().println("Error: Producto o Usuario no encontrado.");
            }
            
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            e.printStackTrace();
            response.getWriter().println("Error crítico al procesar el movimiento: " + e.getMessage());
        } finally {
            if (hibernateSession != null && hibernateSession.isOpen()) {
                hibernateSession.close();
            }
        }
    }
}
