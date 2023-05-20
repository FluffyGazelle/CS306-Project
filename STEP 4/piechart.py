from connect import connectionCreator
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

mydb = connectionCreator()

# print()
# input_continent = input("Please enter the continent you want to create a chart for: ")
query = ''' 
SELECT countries.countries_name, air_pol.indoor + air_pol.outdoor AS total_pollution
FROM countries
JOIN air_pol ON countries.iso_code = air_pol.iso_code
ORDER BY total_pollution DESC
LIMIT 10;
'''

df = pd.read_sql(query,mydb)

print(df.head())

labels = df["countries_name"]
data = df["total_pollution"]
# Plot a pie chart of the cases data for each continent
colors = sns.color_palette('pastel')[0:7]
plt.pie(x=data, labels=labels, colors = colors, autopct='%.0f%%',explode=[0.05]*len(data))
plt.title('10 Countries with the highest air pollution')
plt.show()


