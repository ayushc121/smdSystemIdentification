import sys
import pickle
import numpy as np
import hdf5storage
import os

if os.path.exists("massdamper_full.mat"):
    os.remove("massdamper_full.mat")

# Fix numpy pickle issue
import numpy.core
sys.modules['numpy._core'] = numpy.core

with open("massdamper_data.pkl", "rb") as f:
    data = pickle.load(f)

# ---- Recursive conversion ----
def convert(obj):
    if isinstance(obj, np.ndarray):
        return obj

    if isinstance(obj, np.generic):
        return obj.item()

    if isinstance(obj, (int, float)):
        return obj

    if isinstance(obj, (list, tuple)):
        if all(isinstance(x, (int, float, np.number)) for x in obj):
            return np.array(obj)
        else:
            return [convert(x) for x in obj]

    if isinstance(obj, dict):
        return {k: convert(v) for k, v in obj.items()}

    return obj


clean_data = convert(data)

print("Saving true MATLAB v7.3 file...")

hdf5storage.savemat(
    "massdamper_full.mat",
    {"data": clean_data},
    format='7.3'
)

print("Saved successfully as massdamper_full.mat")
