package com.dolcevida.util;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import com.dolcevida.model.*;

public class HibernateUtil {

    private static final SessionFactory sessionFactory;
    
    static {
        try {
            Configuration cfg = new Configuration();
            
            // 1. Configuración manual de las credenciales de MySQL
            cfg.setProperty("hibernate.connection.driver_class", "com.mysql.cj.jdbc.Driver");
            cfg.setProperty("hibernate.connection.url", "jdbc:mysql://localhost:3306/dolce_vida_inventario?useSSL=false&serverTimezone=UTC");
            cfg.setProperty("hibernate.connection.username", "root");
            cfg.setProperty("hibernate.connection.password", "admin");
            
            // 2. Propiedades del Framework
            cfg.setProperty("hibernate.dialect", "org.hibernate.dialect.MySQL8Dialect");
            cfg.setProperty("hibernate.show_sql", "true");
            cfg.setProperty("hibernate.format_sql", "true");
            
            // 3. Registro explícito de las clases Modelos
            cfg.addAnnotatedClass(Usuario.class);
            cfg.addAnnotatedClass(Categoria.class);
            cfg.addAnnotatedClass(Producto.class);
            cfg.addAnnotatedClass(MovimientoInventario.class);
            cfg.addAnnotatedClass(Factura.class);
            cfg.addAnnotatedClass(DetalleFactura.class);
            
            sessionFactory = cfg.buildSessionFactory();
        } catch (Throwable ex) {
            System.err.println("Error crítico al inicializar Hibernate: " + ex);
            throw new ExceptionInInitializerError(ex);
        }
    }
    
    public static SessionFactory getSessionFactory() {
        return sessionFactory;
    }
}
