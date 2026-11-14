<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.dolcevida.model.Factura"%>
<%@page import="com.dolcevida.model.DetalleFactura"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.dolcevida.util.HibernateUtil"%>
<%
    // PROTECCIÓN DE SESIÓN (ACC-002): Bloquea acceso directo sin login y evita caché
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session.getAttribute("usuarioLogueado") == null) {
        response.sendRedirect("index.html");
        return;
    }
%>
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
        .kpi-box { background: white; border-radius: 14px; padding: 20px; border-left: 5px solid #ff6f91; box-shadow: 0 4px 15px rgba(0,0,0,0.03); flex: 1; }
        .btn-print { background-color: #4a2834; color: white; border: none; border-radius: 8px; padding: 10px 18px; font-weight: 600; cursor: pointer; }
        .btn-print:hover { background-color: #341c24; }
        .btn-detail { background-color: #fdf2f5; color: #7a3e52; border: 1px solid #f5d0db; border-radius: 6px; padding: 4px 10px; font-size: 0.82rem; font-weight: 600; cursor: pointer; }
        .btn-detail:hover { background-color: #7a3e52; color: white; }
        .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 999; align-items: center; justify-content: center; }
        .modal-card { background: white; border-radius: 16px; width: 100%; max-width: 480px; padding: 30px; box-shadow: 0 15px 35px rgba(0,0,0,0.2); }
        @media print {
            .sidebar, .no-print { display: none !important; }
            .main-content { margin-left: 0 !important; padding: 10px !important; }
        }
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
            <li class="mt-5"><a href="${pageContext.request.contextPath}/LogoutController" class="nav-item-link" style="color: #ff8fa3;">🚪 Cerrar sesión</a></li>
        </ul>
    </div>

    <!-- CONTENIDO PRINCIPAL -->
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4" style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
            <div>
                <h2 class="fw-bold text-dark m-0" style="font-weight: bold; font-size: 1.8rem;">Reportes y Balances</h2>
                <small class="text-muted">Monitoreo contable de ingresos y transacciones comerciales</small>
            </div>
            <button type="button" onclick="window.print()" class="btn-print no-print">🖨️ Imprimir / Guardar PDF</button>
        </div>

        <%
            Session hSession = HibernateUtil.getSessionFactory().openSession();
            Double sumaTotal = (Double) hSession.createQuery("SELECT SUM(total) FROM Factura").uniqueResult();
            List<Factura> historialFacturas = hSession.createQuery("FROM Factura ORDER BY idFactura DESC", Factura.class).list();
            List<DetalleFactura> todosDetalles = hSession.createQuery("FROM DetalleFactura", DetalleFactura.class).list();
            if (sumaTotal == null) { sumaTotal = 0.0; }
            int totalFacturas = (historialFacturas != null) ? historialFacturas.size() : 0;
            double ticketPromedio = (totalFacturas > 0) ? (sumaTotal / totalFacturas) : 0.0;
        %>

        <!-- TARJETAS DE INDICADORES FINANCIEROS -->
        <div style="display: flex; gap: 20px; margin-bottom: 30px;">
            <div class="kpi-box" style="background: #fff5f7;">
                <small class="text-muted fw-semibold" style="display: block; font-size: 0.8rem;">TOTAL DE INGRESOS</small>
                <h1 class="fw-bold my-1" style="font-size: 2rem; font-weight: bold; color: #4a2834;">$<%= String.format("%,.0f", sumaTotal) %></h1>
                <small class="text-success fw-semibold" style="font-size: 0.85rem;">💰 Caja general activa</small>
            </div>
            <div class="kpi-box" style="border-left-color: #4a2834;">
                <small class="text-muted fw-semibold" style="display: block; font-size: 0.8rem;">FACTURAS EMITIDAS</small>
                <h1 class="fw-bold my-1" style="font-size: 2rem; font-weight: bold; color: #333;"><%= totalFacturas %></h1>
                <small class="text-muted" style="font-size: 0.85rem;">🧾 Ventas registradas</small>
            </div>
            <div class="kpi-box" style="border-left-color: #198754;">
                <small class="text-muted fw-semibold" style="display: block; font-size: 0.8rem;">PROMEDIO POR VENTA</small>
                <h1 class="fw-bold my-1" style="font-size: 2rem; font-weight: bold; color: #198754;">$<%= String.format("%,.0f", ticketPromedio) %></h1>
                <small class="text-muted" style="font-size: 0.85rem;">📈 Ticket promedio</small>
            </div>
        </div>
        <!-- TABLA HISTÓRICA DE FACTURAS -->
        <div class="report-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px;">
                <h5 class="fw-bold text-dark m-0" style="font-weight: bold;">Auditoría de Ventas Emitidas</h5>
                <input type="text" id="buscadorReportes" onkeyup="filtrarFacturas()" class="form-control no-print" style="max-width: 280px;" placeholder="🔍 Buscar factura o cajero...">
            </div>

            <table class="table table-hover align-middle" style="width: 100%;">
                <thead style="background-color: #f8f9fa; color: #6c757d; font-weight: 600;">
                    <tr>
                        <th style="padding: 12px;">N° Factura</th>
                        <th style="padding: 12px;">Fecha y Hora</th>
                        <th style="padding: 12px;">Cajero Responsable</th>
                        <th style="padding: 12px; text-align: right;">Monto Total</th>
                        <th style="padding: 12px; text-align: center;" class="no-print">Detalle</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        if (historialFacturas != null && !historialFacturas.isEmpty()) {
                            for (Factura f : historialFacturas) {
                                StringBuilder htmlItems = new StringBuilder();
                                if (todosDetalles != null) {
                                    for (DetalleFactura df : todosDetalles) {
                                        if (df.getFactura() != null && df.getFactura().getIdFactura() == f.getIdFactura()) {
                                            double sub = df.getCantidad() * df.getPrecioUnitario();
                                            htmlItems.append("<li style='padding: 8px 0; border-bottom: 1px solid #eee; display: flex; justify-content: space-between;'>")
                                                .append("<span>🍬 <strong>").append(df.getProducto().getNombre().replace("'", "&#39;")).append("</strong> x ").append(df.getCantidad()).append("</span>")
                                                .append("<span style='font-weight: 600;'>$").append(String.format("%,.0f", sub)).append("</span>")
                                                .append("</li>");
                                        }
                                    }
                                }
                    %>
                    <tr class="fila-factura" style="border-bottom: 1px solid #eee;">
                        <td style="padding: 12px; font-weight: 600; color: #4a2834;">FAC-00<%= f.getIdFactura() %></td>
                        <td style="padding: 12px; color: #6c757d;"><%= f.getFecha() %></td>
                        <td style="padding: 12px; font-weight: 500;"><%= (f.getUsuario() != null) ? f.getUsuario().getNombre() : "Cajero" %></td>
                        <td style="padding: 12px; text-align: right; font-weight: bold; color: #198754;">$<%= String.format("%,.0f", f.getTotal()) %></td>
                        <td style="padding: 12px; text-align: center;" class="no-print">
                            <button type="button" class="btn-detail" 
                                onclick="verDetalleFactura('FAC-00<%= f.getIdFactura() %>', '$<%= String.format("%,.0f", f.getTotal()) %>', `<%= htmlItems.toString() %>`)">
                                🔍 Ver productos
                            </button>
                        </td>
                    </tr>
                    <%
                            }
                        } else {
                    %>
                    <tr>
                        <td colspan="5" class="text-center text-muted py-4">No se han registrado transacciones comerciales el día de hoy.</td>
                    </tr>
                    <%
                        }
                        hSession.close();
                    %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- MODAL DETALLE DE FACTURA -->
    <div id="modalDetalleFactura" class="modal-overlay">
        <div class="modal-card">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;">
                <h4 style="margin: 0; font-weight: bold; color: #4a2834;" id="tituloFacturaModal">Detalle de Factura</h4>
                <button type="button" onclick="cerrarModalFactura()" style="border: none; background: none; font-size: 1.3rem; cursor: pointer;">✕</button>
            </div>
            <ul id="listaItemsFactura" style="list-style: none; padding: 0; max-height: 280px; overflow-y: auto; margin-bottom: 15px;">
            </ul>
            <div style="display: flex; justify-content: space-between; font-size: 1.1rem; font-weight: bold; border-top: 2px solid #eee; padding-top: 12px; margin-bottom: 20px;">
                <span>Total Pagado:</span>
                <span style="color: #198754;" id="totalFacturaModal">$0</span>
            </div>
            <button type="button" onclick="cerrarModalFactura()" class="btn-print w-100">Cerrar</button>
        </div>
    </div>

    <script>
        function verDetalleFactura(numFactura, total, htmlItems) {
            document.getElementById("tituloFacturaModal").innerText = "🧾 " + numFactura;
            document.getElementById("totalFacturaModal").innerText = total;
            const ul = document.getElementById("listaItemsFactura");
            if (htmlItems && htmlItems.trim() !== "") {
                ul.innerHTML = htmlItems;
            } else {
                ul.innerHTML = "<li class='text-center text-muted py-3'>Sin detalles registrados para esta factura.</li>";
            }
            document.getElementById("modalDetalleFactura").style.display = "flex";
        }

        function cerrarModalFactura() {
            document.getElementById("modalDetalleFactura").style.display = "none";
        }

        function filtrarFacturas() {
            const texto = document.getElementById("buscadorReportes").value.toLowerCase();
            const filas = document.querySelectorAll(".fila-factura");
            filas.forEach(fila => {
                fila.style.display = fila.innerText.toLowerCase().includes(texto) ? "" : "none";
            });
        }
    </script>

</body>
</html>
