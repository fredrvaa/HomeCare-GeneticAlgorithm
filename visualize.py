# Patient 
#  "care_time": 90,
#  "demand": 10,
#  "end_time": 1057,
#  "start_time": 912,
#  "x_coord": 45,
#  "y_coord": 68
import json
import numpy as np
import matplotlib.pyplot as plt

with open('train/train_6.json', 'r') as file:
    data = json.load(file)

patients = data['patients']
depot = data['depot']

nurses = [[1 + x + n * 20 for x in range(20)] for n in range(5)]

def nurse_list_to_coords(nurses: list, patients: dict) -> np.ndarray:
    nurse_coords = []
    for nurse in nurses:
        coords = (list(map(lambda x: [patients[str(x)]['x_coord'], patients[str(x)]['y_coord']], nurse)))
        coords.insert(0, [depot['x_coord'], depot['y_coord']])
        coords.append([depot['x_coord'], depot['y_coord']])
        nurse_coords.append(coords)
    return np.array(nurse_coords)

nurse_coords = nurse_list_to_coords(nurses, patients)
plt.figure(figsize=(4,4))
for nurse in nurse_coords:
    plt.plot(nurse[:, 0], nurse[:, 1], marker='o')
plt.scatter(depot['x_coord'], depot['y_coord'], color='black', marker='s', s=200)
plt.xlim([0,100])
plt.ylim([0,100])
plt.show()