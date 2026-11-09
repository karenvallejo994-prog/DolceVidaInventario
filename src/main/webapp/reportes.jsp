<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.dolcevida.model.Factura"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.dolcevida.util.HibernateUtil"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dolce Vida - Reportes y Balances</title>
    <link href="css/bootstrap.css" rel="stylesheet">
    <style>
        body { background-color: #f4f6f9; font-family: 'Segoe UI', sans-serif; margin: 0; padding: 0; }
        .sidebar { background-color: #4a2834; min-height: 100vh; color: white; padding-top: 20px; position: fixed; width: 240px; z-index: 100; }
        .sidebar-brand { font-size: 1.5rem; font-weight: bold; padding: 10px 20px; line-height: 1.2; }
        .sidebar-subtitle { font-size: 0.8rem; color: #bca0aa; padding: 0 20px 20px 20px; border-bottom: 1px solid #5c3845; }
        .nav-menu { list-style: none; padding: 20px 0; margin: 0; }
        .nav-item-link { color: #dcbcc6; text-decoration: none; padding: 12px 25px; display: flex; align-items: center; gap: 12px; font-weight: 500; transition: all 0.2s; }
        .nav-item-link:hover, .nav-item-link.active { color: white; background-color: rgba(255,255,255,0.1); border-left: 4px solid #ff6f91; }
        .main-content { margin-left: 240px; padding: 40px; }
        .report-card { background: white; border-radius: 15px; padding: 30px; box-shadow: 0 4px 15px rgba(0,0,0,0.03); }
        .kpi-box { background: #fff5f7; border-radius: 12px; padding: 20px; border-left: 5px solid #ff6f91; margin-bottom: 30px; max-width: 300px; }
    </style>
</head>
<body>

    <!-- MENÚ LATERAL DE NAVEGACIÓN -->
    <div class="sidebar">
        <div class="sidebar-brand">Dolce Vida</div>
        <div class="sidebar-subtitle">Sistema de Inventario</div>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/principal.jsp" class="nav-item-link">🏠 Inicio</a></li>
            <li><a href="${pageContext.request.contextPath}/ProductoController" class="nav-item-link">📦 Inventario</a></li>
            <li><a href="${pageContext.request.contextPath}/categorias.jsp" class="nav-item-link">📁 Categorías</a></li>
            <li><a href="${pageContext.request.contextPath}/alertas.jsp" class="nav-item-link">⚠️ Alertas</a></li>
            <li><a href="${pageContext.request.contextPath}/facturacion.jsp" class="nav-item-link">🧾 Facturación</a></li>
            <li><a href="${pageContext.request.contextPath}/reportes.jsp" class="nav-item-link active">📊 Reportes</a></li>
            <li class="mt-5"><a href="${pageContext.request.contextPath}/index.html" class="nav-item-link" style="color: #ff8fa3;">🚪 Cerrar sesión</a></li>
        </ul>
    </div>

    <!-- CONTENIDO PRINCIPAL -->
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-dark m-0" style="font-weight: bold; font-size: 1.8rem;">Reportes y Balances</h2>
                <small class="text-muted">Monitoreo contable de ingresos y transacciones comerciales</small>
            </div>
        </div>

        <%
            Session hSession = HibernateUtil.getSessionFactory().openSession();
            // Ejecutamos una consulta HQL real para sumar los montos de todas las facturas cobradas
            Double sumaTotal = (Double) hSession.createQuery("SELECT SUM(total) FROM Factura").uniqueResult();
            List<Factura> historialFacturas = hSession.createQuery("FROM Factura ORDER BY idFactura DESC", Factura.class).list();
            if (sumaTotal == null) { sumaTotal = 0.0; }
        %>

        <!-- TARJETA INFORMATIVA DEL TOTAL RECAUDADO -->
        <div class="kpi-box">
            <small class="text-muted fw-semibold uppercase" style="display: block; font-size: 0.8rem; letter-spacing: 0.5px;">TOTAL DE INGRESOS</small>
            <h1 class="fw-bold text-dark my-1" style="font-size: 2.2rem; font-weight: bold; color: #4a2834 !important;">$<%= String.format("%,.0f", sumaTotal) %></h1>
            <small class="text-success fw-semibold" style="font-size: 0.85rem;">💰 Caja general activa</small>
        </div>
        <!-- TABLA HISTÓRICA DE FACTURAS -->
        <div class="report-card">
            <h5 class="fw-bold text-dark mb-4" style="font-weight: bold;">Auditoría de Ventas Emitidas</h5>
            <table class="table table-hover align-middle" style="width: 100%;">
                <thead style="background-color: #f8f9fa; color: #6c757d; font-weight: 600;">
                    <tr>
                        <th style="padding: 12px;">N° Factura</th>
                        <th style="padding: 12px;">Fecha y Hora</th>
                        <th style="padding: 12px;">Cajero Responsable</th>
                        <th style="padding: 12px; text-align: right;">Monto Total</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (historialFacturas != null && !historialFacturas.isEmpty()) {
                            for (Factura f : historialFacturas) {
                    %>
                    <tr style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px; font-weight: 600; color: #4a2834;">FAC-00<%= f.getIdFactura() %></td>
                        <td style="padding: 12px; color: #6c757d;"><%= f.getFecha() %></td>
                        <td style="padding: 12px; font-weight: 500;"><%= f.getUsuario().getNombre() %></td>
                        <td style="padding: 12px; text-align: right; font-weight: bold; color: #198754;">$<%= String.format("%,.0f", f.getTotal()) %></td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="4" class="text-center text-muted py-4">No se han registrado transacciones comerciales el día de hoy.</td>
                    </tr>
                    <%
                        }
                        hSession.close();
                    %>
                </tbody>
            </table>
        </div>
    </div>

</body>
</html>
