

import os
import re
import pandas as pd

pd.set_option("display.width", 120)
pd.set_option("display.max_columns", None)

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RUTA_SUCIO = os.path.join(BASE_DIR, "data", "csv_sucio.csv")
RUTA_LIMPIO = os.path.join(BASE_DIR, "data", "csv_limpio.csv")

CATEGORIAS_VALIDAS = ["Retail", "Services", "Education", "Food"]
CIUDADES_VALIDAS = [
    "Guatemala", "Antigua", "Villa Nueva", "Mixco", "Amatitlan",
    "Quetzaltenango", "Chimaltenango", "Escuintla",
]


def line(title):
    print("\n\n\n")
    print(title)
    print("\n")



# 1. CARGA DEL DATASET
df_original = pd.read_csv(RUTA_SUCIO, skip_blank_lines=True)

line("1. ESTADO ORIGINAL DEL DATASET (crudo, sin tratar)")
print(f"Filas: {df_original.shape[0]}  |  Columnas: {df_original.shape[1]}")
print(df_original.head(10))
print("\nTipos de dato originales:")
print(df_original.dtypes)
print("\nValores nulos / vacios por columna (antes):")
print(df_original.isna().sum())

pivot_antes = df_original.pivot_table(
    index="categoria",
    values="id_cliente",
    aggfunc="count",
    dropna=False,
)
pivot_antes.columns = ["conteo_registros"]
print("\nPivote ANTES (categoria SIN normalizar, texto crudo) -> conteo de registros:")
print(pivot_antes)
print("(Notese que 'Retail', 'RETAIL', 'retail' y 'Retail ' se cuentan como categorias DISTINTAS)")



# 2. COPIA DE TRABAJO
df = df_original.copy()

filas_iniciales = len(df)



# 3. ELIMINACION DE DUPLICADOS
line("3. ELIMINACION DE DUPLICADOS")

dup_exactos = df.duplicated().sum()
df = df.drop_duplicates()
print(f"Duplicados EXACTOS (fila completa) eliminados: {dup_exactos}")

# id_cliente es la llave de negocio: no deberian repetirse.
dup_id = df.duplicated(subset=["id_cliente"]).sum()
df = df.drop_duplicates(subset=["id_cliente"], keep="first")
print(f"Duplicados por id_cliente (llave de negocio) eliminados: {dup_id}")

print(f"Filas restantes tras deduplicar: {len(df)}")



# 4. ESTANDARIZACION DE VALORES Y FORMATOS
line("4. ESTANDARIZACION DE VALORES Y FORMATOS")

# --- nombre: quitar espacios extra, espacios dobles, y formato "Title Case"
df["nombre"] = (
    df["nombre"]
    .astype(str)
    .str.strip()
    .str.replace(r"\s+", " ", regex=True)
    .str.title()
)

# --- genero: normalizar a 'M' / 'F', vacios -> "No especificado"
df["genero"] = df["genero"].astype(str).str.strip().str.upper()
df["genero"] = df["genero"].replace({"NAN": ""})
df["genero"] = df["genero"].apply(lambda x: x if x in ("M", "F") else "No especificado")

# --- fecha_registro: dos formatos mezclados -> YYYY-MM-DD (ISO-8601)
def normalizar_fecha(valor):
    valor = str(valor).strip()
    for fmt in ("%Y-%m-%d", "%d/%m/%Y"):
        try:
            return pd.to_datetime(valor, format=fmt).strftime("%Y-%m-%d")
        except ValueError:
            continue
    return pd.NaT

df["fecha_registro"] = df["fecha_registro"].apply(normalizar_fecha)

# --- gasto_q: coma decimal ("373,33") y punto decimal (371.80) mezclados
def normalizar_gasto(valor):
    if pd.isna(valor):
        return pd.NA
    valor = str(valor).strip()
    if valor == "":
        return pd.NA
    valor = valor.replace(",", ".")
    try:
        return round(float(valor), 2)
    except ValueError:
        return pd.NA

df["gasto_q"] = df["gasto_q"].apply(normalizar_gasto)
df["gasto_q"] = pd.to_numeric(df["gasto_q"], errors="coerce")

# --- ciudad: espacios extra, mayus/minus mezcladas, "NA" como texto
df["ciudad"] = (
    df["ciudad"]
    .astype(str)
    .str.strip()
    .str.replace(r"\s+", " ", regex=True)
    .str.title()
)
df["ciudad"] = df["ciudad"].replace({"Na": pd.NA, "": pd.NA, "Nan": pd.NA})

# --- categoria: espacios extra y mayus/minus mezcladas -> catalogo fijo
df["categoria"] = (
    df["categoria"]
    .astype(str)
    .str.strip()
    .str.title()
)

print("Reglas de estandarizacion aplicadas:")
print(" - nombre: trim + colapso de espacios + Title Case")
print(" - genero: normalizado a 'M' / 'F' / 'No especificado'")
print(" - fecha_registro: formatos mixtos (YYYY-MM-DD y DD/MM/YYYY) -> ISO-8601 YYYY-MM-DD")
print(" - gasto_q: coma decimal -> punto decimal, castigado a float(2)")
print(" - ciudad: trim + colapso de espacios + Title Case + 'NA' -> nulo")
print(" - categoria: trim + Title Case (Retail/Services/Education/Food)")



# 5. TRATAMIENTO DE CELDAS VACIAS (NULOS)

line("5. TRATAMIENTO DE CELDAS VACIAS")
print("Nulos detectados tras estandarizar (antes de imputar):")
print(df.isna().sum())

# gasto_q: imputar con la MEDIANA de su categoria (mas robusta que la media
# ante outliers); si la categoria completa no tuviera datos, usar mediana global.
mediana_global = df["gasto_q"].median()
df["gasto_q"] = df.groupby("categoria")["gasto_q"].transform(
    lambda s: s.fillna(s.median())
)
df["gasto_q"] = df["gasto_q"].fillna(mediana_global).round(2)

# ciudad: nulos -> "No especificado" (se documenta explicitamente, no se
# inventa una ciudad)
df["ciudad"] = df["ciudad"].fillna("No especificado")

# fecha_registro: si quedara alguna fecha invalida/no parseable, se descarta
# la fila porque es un campo clave para analisis temporal.
filas_antes_fecha = len(df)
df = df.dropna(subset=["fecha_registro"])
filas_fecha_eliminadas = filas_antes_fecha - len(df)

print(f"\nFilas eliminadas por fecha_registro invalida/irrecuperable: {filas_fecha_eliminadas}")
print("gasto_q vacio -> imputado con la mediana de su categoria")
print("ciudad vacia / 'NA' -> imputado como 'No especificado'")

print("\nNulos restantes (debe ser 0 en todas las columnas):")
print(df.isna().sum())



# 6. AJUSTE FINAL DE TIPOS (dataset listo para un motor de BD)
df["id_cliente"] = df["id_cliente"].astype(int)
df["fecha_registro"] = pd.to_datetime(df["fecha_registro"]).dt.date
df["gasto_q"] = df["gasto_q"].astype(float).round(2)
df = df.sort_values("id_cliente").reset_index(drop=True)



# 7. ESTADO DEPURADO
line("7. ESTADO DEPURADO DEL DATASET (despues de limpiar)")
print(f"Filas: {df.shape[0]}  |  Columnas: {df.shape[1]}")
print(df.head(10))
print("\nTipos de dato finales:")
print(df.dtypes)

pivot_despues = df.pivot_table(
    index="categoria",
    values="gasto_q",
    aggfunc=["count", "mean"],
)
print("\nPivote DESPUES (categoria normalizada) -> count/mean de gasto_q:")
print(pivot_despues)

pivot_ciudad = df.pivot_table(
    index="ciudad",
    columns="genero",
    values="id_cliente",
    aggfunc="count",
    fill_value=0,
)
print("\nPivote DESPUES: clientes por ciudad y genero:")
print(pivot_ciudad)




# 8. EXPORTAR CSV LIMPIO
df.to_csv(RUTA_LIMPIO, index=False, encoding="utf-8")
line(f"Archivo limpio exportado en: {RUTA_LIMPIO}")
