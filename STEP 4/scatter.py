from connect import connectionCreator
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

mydb = connectionCreator()

query = ''' 
SELECT a.iso_code, c.countries_name, a.smoke, a.alcohol
FROM addiction a
JOIN countries c ON a.iso_code = c.iso_code
WHERE a.smoke < 3000 AND a.alcohol < 3000;
'''

df = pd.read_sql(query, mydb)

plt.figure(figsize=(10,8))
sns.scatterplot(x='smoke', y='alcohol', data=df)
sns.regplot(x='smoke', y='alcohol', data=df)
plt.xlabel('Smoke')
plt.ylabel('Alcohol')
plt.title('Scatter plot of Smoke vs Alcohol Consumption')
plt.show()