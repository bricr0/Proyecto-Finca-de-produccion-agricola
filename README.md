# 🌱 Sistema de Gestión Agrícola  

*Creado por Brigitte Claros Viola y Juan Sebastian Martinez Tapias*
*Sistema integral para la administración de fincas y cultivos*  

---

## 📋 Descripción  
**Gestión Agrícola** es una solución desarrollada en **C# (.NET)** con **MySQL** para optimizar procesos en el sector agropecuario. Permite:  

- 🚜 **Gestión de cultivos y parcelas**  
- 📊 **Seguimiento de inventarios (insumos, herramientas)**  
- ⏲ **Planificación de actividades (siembra, riego, cosecha)**  
- 🌦 **Registro de variables climáticas**  
- 📈 **Generación de reportes y métricas**  

---

## 🛠 Requisitos Técnicos  

| Componente       | Versión  |
|------------------|----------|
| .NET             | 6.0+     |
| MySQL Server     | 8.0+     |
| IDE              | Visual Studio 2022+ |
| Paquetes NuGet   | `MySql.Data`, `Dapper`, `LiveCharts` |

---

## ⚙️ Configuración Inicial  

### 1. Base de Datos  
Ejecuta el script SQL ubicado en:  
```bash
./Database/Script_Creacion.sql
```  
> 📌 *Asegúrate de configurar las credenciales en `appsettings.json`*  

### 2. Variables de Entorno  
Crea un archivo `.env` en la raíz del proyecto:  
```ini
DB_SERVER=localhost
DB_NAME=gestion_agricola
DB_USER=tu_usuario
DB_PASSWORD=tu_contraseña
```  

### 3. Instalación de Dependencias  
```bash
dotnet restore
```  

---

## 🚀 Ejecución del Proyecto  
1. **Modo Desarrollo**:  
   ```bash
   dotnet run --environment Development
   ```  
2. **Modo Producción**:  
   ```bash
   dotnet publish -c Release
   ```  

---

## 📂 Estructura del Proyecto  
```markdown
📦 GestionAgricola  
├── 📂 Controllers      # Lógica de negocio  
├── 📂 Models           # Entidades y DTOs  
├── 📂 Data             # Conexión a DB  
├── 📂 Views            # Interfaz gráfica (WinForms/WPF)  
├── 📂 Reports          # Reportes (PDF/Excel)  
└── 📂 Scripts          # Consultas SQL adicionales  
```  

---

## 🔍 Consultas Importantes  
Ejemplos de consultas frecuentes (ubicadas en `Scripts/Queries.sql`):  

```sql
-- Obtener cultivos activos  
SELECT * FROM Cultivos WHERE Activo = 1;  

-- Calcular rendimiento por hectárea  
SELECT ParcelaID, SUM(CosechaKG)/Area_Hectareas AS Rendimiento  
FROM Cosechas  
GROUP BY ParcelaID;  
```  

---

## 📅 Eventos Programados  
El sistema incluye automatizaciones:  

| Evento                  | Frecuencia   | Descripción                          |  
|-------------------------|--------------|--------------------------------------|  
| `ActualizarClima`       | Diario       | Sincroniza datos meteorológicos      |  
| `GenerarBackup`         | Semanal      | Respaldos automáticos de la base de datos |  

---

## 📜 Licencia  
Este proyecto está bajo la licencia **MIT**.  

---  

<div align="center">  
  ✨ **¡Contribuciones son bienvenidas!** ✨  
  <sub>¿Encontraste un bug? ¡Abre un *issue* o envía un *PR*!</sub>  
</div>  

--- 

### 📧 Contacto  
**Equipo de Desarrollo**  
📩 agricola.dev@example.com  
🌐 [www.gestionagricola.com](https://www.gestionagricola.com)  

---  

> 💡 *¿Necesitas ayuda?* Revisa nuestra [Wiki](https://github.com/tu-repositorio/wiki) para documentación adicional.  

--- 

**🎉 ¡Feliz cultivo de código! 🎉**  

</br>  

<div align="right">  
  <sub>🔄 Última actualización: Agosto 2025</sub>  
</div>  

---  

### ✨ Características Adicionales  
- **Dashboard interactivo** con gráficos en tiempo real  
- **Sistema de alertas** para plagas o condiciones adversas  
- **API REST** para integración con apps móviles  

---  

```csharp
// Ejemplo de código C# (LoginService.cs)  
public class AuthService  
{  
    public bool Login(string user, string pass)  
    {  
        // Lógica de autenticación  
    }  
}  
```  

---  

**🔗 Enlaces Rápidos**  
[Documentación API](https://api.gestionagricola.com/docs) | [Manual de Usuario](https://github.com/tu-repo/manual.pdf) | [Changelog](https://github.com/tu-repo/CHANGELOG.md)