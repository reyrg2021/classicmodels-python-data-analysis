from sqlalchemy import create_engine, inspect, text
import pandas as pd
import psycopg2 
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
param_db = {
    'HOST': 'localhost',
    'USERNAME': 'postgres',
    'PASSWORD': 12345,
    'DATABASE' : 'g108_classicmodels',
    'PORT': 5432
}
engine = create_engine(f"postgresql://{param_db['USERNAME']}:{param_db['PASSWORD']}@{param_db['HOST']}/{param_db['DATABASE']}")

def create_DB():
    """
    Solo crea DB si no existe
    """
    conn = None
    try:
        conn = psycopg2.connect(
            dbname='postgres', 
            user=param_db['USERNAME'], 
            password=param_db['PASSWORD'], 
            host=param_db['HOST'],
            port=param_db['PORT']
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        # Verificar si la BD existe
        check_query = f"""
        SELECT 1 FROM pg_database WHERE datname = '{param_db['DATABASE']}';
        """
        cursor.execute(check_query)
        exists = cursor.fetchone()
        
        if exists:
            print(f"Base de datos {param_db['DATABASE']} ya existe. Usando existente.")
        else:
            create_query = f"CREATE DATABASE {param_db['DATABASE']};"
            cursor.execute(create_query)
            print(f"Base de datos {param_db['DATABASE']} creada exitosamente")
            
    except Exception as e:
        print(f"Error: {e}")
        raise
    finally:
        if conn:
            conn.close()


def acond_DB():
    """
    Acondiciona la BD importando el archivo SQL con manejo de duplicados
    """
    conn = None
    try:
        conn = psycopg2.connect(
            dbname=param_db['DATABASE'], 
            user=param_db['USERNAME'], 
            password=param_db['PASSWORD'], 
            host=param_db['HOST'],
            port=param_db['PORT']
        )
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cursor = conn.cursor()
        
        ARCHIVO = "./DB/classicmodels_insert.sql"
        
        # OPCIÓN 1: Limpiar BD antes de importar
        print("Limpiando tablas existentes...")
        cleanup_tables = [
            'orderdetails', 'orders', 'customers', 
            'employees', 'products','top_10_clientes_2005','top_10_productos_2005',
            'offices','payments','productlines'

        ]
        
        for table in cleanup_tables:
            try:
                cursor.execute(f"DROP TABLE IF EXISTS {table} CASCADE;")
                print(f"Tabla {table} eliminada (si existía)")
            except Exception as e:
                print(f"Advertencia al eliminar {table}: {e}")
        
        # Importar archivo SQL
        print("Importando archivo SQL...")
        with open(ARCHIVO, "r", encoding='utf-8') as file:
            query = file.read()
        
        cursor.execute(query)
        conn.commit()
        print('Archivo classicmodels_insert.sql ejecutado correctamente')
        
    except FileNotFoundError:
        print(f"Error: No se encuentra el archivo {ARCHIVO}")
        raise
    except Exception as e:
        print(f"Error al acondicionar BD: {e}")
        raise
    finally:
        if conn:
            conn.close()


def leer_tabla(tabla):
    query = f"select * from {tabla};"
    df = pd.read_sql(query, engine )
    return df

def escribir_BD(df,table_name):
    print(f"Empezando a escribir la tabla {table_name}")
    df.to_sql(table_name,engine,if_exists = 'replace')
    print(f"Terminando de escribir la tabla {table_name}")

def filt_DF_fechas(df_in, col, type, **kwargs):
    """
    Filtra DataFrame por fechas usando diferentes tipos de filtro

    """
    # df["orderDate"] = pd.to_datetime(df_base["orderDate"], format="%Y-%m-%d")
    df_in[col] = pd.to_datetime(df_in[col], format="%Y-%m-%d")
    # df["shippedDate"] = pd.to_datetime(df_base["shippedDate"], format="%Y-%m-%d")

     # Filtrar primero por tipo, luego manejar kwargs según cada caso
    if type == 'año':
        # Requiere: año=2005
        año_valor = kwargs.get('año', 2005)  # Default 2005 si no se especifica
        df_out = df_in[df_in[col].dt.year == año_valor]
        
    elif type == 'mes':
        # Puede recibir: mes=6 (usa año default) o año=2005, mes=6
        año_valor = kwargs.get('año', 2005)
        mes_valor = kwargs.get('mes', 1)
        df_out = df_in[(df_in[col].dt.year == año_valor) & 
                      (df_in[col].dt.month == mes_valor)]
        
    elif type == 'dia':
        # Puede recibir: dia=15 (usa defaults) o año=2005, mes=6, dia=15
        año_valor = kwargs.get('año', 2005)
        mes_valor = kwargs.get('mes', 1)
        dia_valor = kwargs.get('dia', 1)
        df_out = df_in[(df_in[col].dt.year == año_valor) & 
                      (df_in[col].dt.month == mes_valor) &
                      (df_in[col].dt.day == dia_valor)]
        
    elif type == 'rango':
        # Requiere: fecha_inicio='2005-01-01', fecha_fin='2005-12-31'
        fecha_inicio = pd.to_datetime(kwargs.get('fecha_inicio'))
        fecha_fin = pd.to_datetime(kwargs.get('fecha_fin'))
        df_out = df_in[(df_in[col] >= fecha_inicio) & 
                      (df_in[col] <= fecha_fin)]
        
    else:
        # Tipo no reconocido, retornar DataFrame original
        print(f"Tipo '{type}' no reconocido. Tipos válidos: 'año', 'mes', 'dia', 'rango'")
        df_out = df_in.copy()
        
    return df_out

def generar_reporte_pivotado(df, filas, columnas=None, valores=None, funcion_agrupadora='sum'):
    """
    Genera un reporte pivotado según parámetros de entrada, con soporte para columnas opcionales.

    """
    # Construcción flexible del pivot_table
    pivot_kwargs = {
        'index': filas,
        'values': valores,
        'aggfunc': funcion_agrupadora,
        'fill_value': 0
    }
    
    if columnas is not None:
        pivot_kwargs['columns'] = columnas
    
    return pd.pivot_table(df, **pivot_kwargs)