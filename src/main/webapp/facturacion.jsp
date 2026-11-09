<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.List"%>
<%@page import="com.dolcevida.model.Producto"%>
<%@page import="org.hibernate.Session"%>
<%@page import="com.dolcevida.util.HibernateUtil"%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dolce Vida - Módulo de Facturación</title>
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
        .billing-panel { background: white; border-radius: 15px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.02); height: 100%; min-height: 520px; }
        .search-box { border-radius: 8px; border: 1px solid #dee2e6; padding: 10px 15px; width: 100%; margin-bottom: 20px; }
        .product-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; }
        .product-item-card { border: 1px solid #eee; border-radius: 10px; padding: 15px; background-color: #fff; text-align: center; }
        .product-name { font-weight: bold; color: #333; margin: 0; font-size: 1.05rem; }
        .product-price { color: #4a2834; font-weight: 700; margin: 2px 0; font-size: 1.2rem; }
        .product-stock { font-size: 0.85rem; color: #6c757d; margin-bottom: 10px; }
        .btn-add-item { background-color: #4a2834; color: white; border: none; border-radius: 6px; width: 100%; padding: 8px; font-size: 0.9rem; font-weight: 600; }
        .btn-add-item:hover { background-color: #341c24; color: white; }
        .invoice-input { border-radius: 6px; border: 1px solid #dee2e6; padding: 8px; font-size: 0.9rem; width: 100%; }
        .btn-register-sale { background-color: #198754; color: white; border: none; border-radius: 8px; padding: 12px; font-weight: bold; width: 100%; margin-top: 15px; }
        .btn-register-sale:hover { background-color: #146c43; color: white; }
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
            <li><a href="${pageContext.request.contextPath}/facturacion.jsp" class="nav-item-link active">🧾 Facturación</a></li>
            <li><a href="${pageContext.request.contextPath}/reportes.jsp" class="nav-item-link">📊 Reportes</a></li>
            <li class="mt-5"><a href="${pageContext.request.contextPath}/index.html" class="nav-item-link" style="color: #ff8fa3;">🚪 Cerrar sesión</a></li>
        </ul>
    </div>

    <!-- CUERPO DE FACTURACIÓN EN DOS COLUMNAS -->
    <div class="main-content">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <h2 class="fw-bold text-dark m-0" style="font-weight: bold; font-size: 1.8rem;">Módulo de Facturación</h2>
                <small class="text-muted">Caja registradora virtual</small>
            </div>
        </div>

        <div class="row g-4" style="display: flex; gap: 20px; align-items: start;">
            
            <!-- COLUMNA IZQUIERDA: BUSCAR Y AGREGAR PRODUCTOS -->
            <div style="flex: 1; max-width: 50%;">
                <div class="billing-panel">
                    <h5 class="fw-bold text-dark mb-3" style="font-weight: bold;">Buscar y Agregar Productos</h5>
                    <input type="text" class="search-box" placeholder="Buscar por nombre o código de producto...">
                    
                    <div class="product-grid">
                        <%
                            Session hSession = HibernateUtil.getSessionFactory().openSession();
                            List<Producto> catalogoCaja = hSession.createQuery("FROM Producto WHERE cantidad > 0", Producto.class).list();
                            if (catalogoCaja != null && !catalogoCaja.isEmpty()) {
                                for (Producto p : catalogoCaja) {
                        %>
                        <div class="product-item-card">
                            <p class="product-name"><%= p.getNombre() %></p>
                            <p class="product-price">$<%= String.format("%,.0f", p.getPrecio()) %></p>
                            <p class="product-stock">Stock: <%= p.getCantidad() %></p>
                            <button type="button" class="btn-add-item" onclick="agregarAlDetalle(<%= p.getIdProducto() %>, '<%= p.getNombre() %>', <%= p.getPrecio() %>)">+ Agregar</button>
                        </div>
                        <%
                                }
                            }
                            hSession.close();
                        %>
                    </div>
                </div>
            </div>
            <!-- COLUMNA DERECHA: LIQUIDACIÓN DE LA VENTA -->
            <div style="flex: 1; max-width: 50%;">
                <div class="billing-panel">
                    <h5 class="fw-bold text-dark mb-4" style="font-weight: bold;">Detalle de Venta</h5>
                    
                    <form action="FacturaController" method="POST">
                        <input type="hidden" name="idProducto" id="formIdProducto" value="">
                        <input type="hidden" name="cantidad" id="formCantidad" value="1">

                        <div class="row g-3 mb-4" style="display: flex; gap: 10px; margin-bottom: 20px;">
                            <div style="flex: 1;"><input type="text" class="invoice-input" placeholder="Nombre del cliente (Opcional)"></div>
                            <div style="flex: 1;"><input type="text" class="invoice-input" placeholder="Documento / Cédula" required></div>
                        </div>

                        <table class="table align-middle mb-4" style="width: 100%; font-size: 0.9rem;">
                            <thead style="background-color: #f8f9fa; color: #6c757d;">
                                <tr>
                                    <th style="padding: 8px;">Producto</th>
                                    <th style="padding: 8px; text-align: center;">Cant.</th>
                                    <th style="padding: 8px; text-align: right;">Precio</th>
                                    <th style="padding: 8px; text-align: right;">Subtotal</th>
                                </tr>
                            </thead>
                            <tbody id="tablaDetalleVenta">
                                <tr id="filaMensajeVacio">
                                    <td colspan="4" class="text-center text-muted py-4">Ningún producto seleccionado en el detalle.</td>
                                </tr>
                            </tbody>
                        </table>

                        <hr style="color: #eee; margin: 20px 0;">

                        <div class="d-flex justify-content-between mb-2" style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                            <span class="text-muted">Subtotal:</span>
                            <span class="fw-semibold text-secondary" id="txtSubtotal">$0</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2" style="display: flex; justify-content: space-between; margin-bottom: 8px;">
                            <span class="text-muted">IVA (0% / Exento):</span>
                            <span class="fw-semibold text-secondary">$0</span>
                        </div>
                        <div class="d-flex justify-content-between mb-4" style="display: flex; justify-content: space-between; margin-bottom: 25px; font-size: 1.2rem;">
                            <span class="fw-bold text-dark" style="font-weight: bold;">Total a Pagar:</span>
                            <span class="fw-bold text-dark" style="font-weight: bold;" id="txtTotal">$0</span>
                        </div>

                        <div class="row g-2" style="display: flex; gap: 10px;">
                            <div style="flex: 1;"><a href="facturacion.jsp" class="btn btn-light w-100 py-2 border" style="width:100%; text-decoration:none; display:block; text-align:center; color:#333; background:#f8f9fa; border-radius: 6px;">Cancelar</a></div>
                            <div style="flex: 1;"><button type="submit" class="btn-register-sale" style="margin-top:0px;">Registrar Venta 📑</button></div>
                        </div>
                    </form>
                </div>
            </div>
            
        </div>
    </div>

    <!-- ENLACE DE DATOS EN VIVO JAVASCRIPT -->
    <script>
    function agregarAlDetalle(id, nombre, precio) {
        const mensaje = document.getElementById("filaMensajeVacio");
        if (mensaje) { mensaje.style.display = "none"; }

        const tabla = document.getElementById("tablaDetalleVenta");
        tabla.innerHTML = `
            <tr style="border-bottom: 1px solid #f8f9fa;">
                <td style="padding: 8px; font-weight: 500;">\${nombre}</td>
                <td style="padding: 8px; text-align: center;"><span class="badge bg-secondary" style="color: white; padding: 4px 8px;">1</span></td>
                <td style="padding: 8px; text-align: right;">$\${precio.toLocaleString()}</td>
                <td style="padding: 8px; text-align: right; font-weight: bold;">$\${precio.toLocaleString()}</td>
            </tr>
        `;

        document.getElementById("txtSubtotal").innerText = "$" + precio.toLocaleString();
        document.getElementById("txtTotal").innerText = "$" + precio.toLocaleString();

        document.getElementById("formIdProducto").value = id;
    }
    </script>
</body>
</html>
