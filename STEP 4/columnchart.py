from connect import connectionCreator
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

mydb = connectionCreator()

countries = ['TUR', 'USA', 'GBR', 'VNM', 'FIN', 'BGR']  # Choose the countries you are interested in

for country in countries:
    query = f'''
    SELECT child_wasting, non_bfeeding, low_birth_weight
    FROM child_mortality
    WHERE iso_code = '{country}';
    '''

    df = pd.read_sql(query,mydb)
    health_indicators = df.columns
    values = df.loc[0]
    
    plt.plot(health_indicators, values, label=country)

plt.xlabel('Health Indicators')
plt.ylabel('Values')
plt.title('Health Indicators in Different Countries')
plt.legend()
plt.show()
