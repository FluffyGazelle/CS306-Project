from connect import connectionCreator
import pandas as pd
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt

mydb = connectionCreator()


query = ''' 
SELECT c.countries_name, a.drug_use
FROM addiction a
JOIN countries c ON a.iso_code = c.iso_code
ORDER BY a.drug_use DESC
LIMIT 5;

'''

df = pd.read_sql(query,mydb)

print(df.head())

# Plot a barplot of the ratio data
sns.barplot(x='countries_name', y='drug_use', data=df)
plt.xlabel('Country')
plt.ylabel('Drug Usage')
plt.title('Drug Usage of countries')
plt.show()


