package com.dolcevida.model;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;

@Entity
@Table(name = "movimientos_inventario")
public class MovimientoInventario implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_movimiento")
    private int idMovimiento;

    @ManyToOne
    @JoinColumn(name = "id_producto", nullable = false)
    private Producto producto;

    @ManyToOne
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;

    @Column(name = "tipo_movimiento", nullable = false)
    private String tipoMovimiento; // ENUM guardado como String ('ENTRADA', 'SALIDA', 'AJUSTE')

    @Column(name = "cantidad", nullable = false)
    private int cantidad;

    @Column(name = "fecha_movimiento", nullable = false)
    @Temporal(TemporalType.TIMESTAMP)
    private Date fechaMovimiento;

    @Column(name = "observacion", length = 255)
    private String observacion;

    public MovimientoInventario() {}

    public int getIdMovimiento() { return idMovimiento; }
    public void setIdMovimiento(int idMovimiento) { this.idMovimiento = idMovimiento; }

    public Producto getProducto() { return producto; }
    public void setProducto(Producto producto) { this.producto = producto; }

    public Usuario getUsuario() { return usuario; }
    public void setUsuario(Usuario usuario) { this.usuario = usuario; }

    public String getTipoMovimiento() { return tipoMovimiento; }
    public void setTipoMovimiento(String tipoMovimiento) { this.tipoMovimiento = tipoMovimiento; }

    public int getCantidad() { return cantidad; }
    public void setCantidad(int cantidad) { this.cantidad = cantidad; }

    public Date getFechaMovimiento() { return fechaMovimiento; }
    public void setFechaMovimiento(Date fechaMovimiento) { this.fechaMovimiento = fechaMovimiento; }

    public String getObservacion() { return observacion; }
    public void setObservacion(String observacion) { this.observacion = observacion; }
}
