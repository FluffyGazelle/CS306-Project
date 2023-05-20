#Muammer Tunahan Yildiz | 27968

import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import plotly.graph_objects as go
import mysql.connector
from mysql.connector import Error

# Establish a connection to the database
def connect_to_database():
    try:
        connection = mysql.connector.connect(
            host='localhost',
            user='root',
            password='tunahan291',
            database='deaths'
        )
        print("Connected to the database!")
        return connection

    except mysql.connector.Error as error:
        print("Failed to connect to the database: {}".format(error))
        return None

# Close the database connection
def close_connection(connection):
    if connection and connection.is_connected():
        connection.close()
        print("Connection closed.")

# Example usage
connection = connect_to_database()

if connection:
    try:
        # Create a cursor object to interact with the database
        cursor = connection.cursor()

        # Example query
        cursor.execute('''SELECT c.countries_name, c.iso_code, env.unsafe_water + env.unsafe_sanitation + env.hand_washing AS total_sanitation
FROM countries c
JOIN env_factor env ON c.iso_code = env.iso_code;
        ''')
        rows = cursor.fetchall()

        # Convert query result into a DataFrame
        columns = [column[0] for column in cursor.description]
        df = pd.DataFrame(rows, columns=columns)

        # Close the cursor
        cursor.close()


        print(df.head(5))
        
        fig = go.Figure(data=go.Choropleth(
        locations = df['iso_code'],
        z = df['total_sanitation'],
        text = df['countries_name'],
        colorscale = 'Inferno',
        autocolorscale=False,
        reversescale=True,
        marker_line_color='darkgray',
        marker_line_width=0.5,
        colorbar_title = 'Deaths/Year',
        zmax=100000,
        zmin=0
        
        ))
        fig.update_layout(
        width=1000,
        height=620,
        geo=dict(
        showframe=False,
        showcoastlines=False,
        projection_type='equirectangular'
        ),
        title={
        'text': '<b>Deaths Caused By Unaccessible Clean Water Sources</b>',
        'y':0.9,
        'x':0.5,
        'xanchor': 'center',
        'yanchor': 'top',
        },
        title_font_color='#525252',
        title_font_size=26,
        font=dict(
        family='Heebo', 
        size=18, 
        color='#525252'
        )
        )
        fig.show()
        
    except mysql.connector.Error as error:
        print("Error executing query: {}".format(error))

    finally:
        # Close the connection
        close_connection(connection)

