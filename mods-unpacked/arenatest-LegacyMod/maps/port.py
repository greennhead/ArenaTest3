import tkinter as tk
from tkinter import filedialog

root = tk.Tk()
root.withdraw()
text = "hello"
newtext = ""
print("Load old map json...")
file_path = filedialog.askopenfilename(
    title="Choose old arenatest map file...",
    filetypes=[('json please!', '.json'), ('scary', '.*')],
               )

print(file_path)
with open(file_path,"r") as f:
    text = f.read()
    for lin in text.splitlines():
        line = lin
        if "res://nodes/block.tscn" in line:
            line = line.replace('"rotation_x":0.0,"rotation_y":0.0,"rotation_z":0.0,','')
        line = line.replace('\"parent\":\"/root/Map_editor\",','')
        line = line.replace('res://nodes/','')
        line = line.replace('.tscn','')
        line = line.replace('\"filename\":','\"name\":')
        newtext += line + "\n"
    f.close()




savepath = open(filedialog.asksaveasfilename(    title="Save your new map... dont overwrite because wont work",
    filetypes=[('it\'s a json!', '.json'), ('what!', '.*')],defaultextension='.json'),"x+")
f = savepath
f.write(newtext)
f.truncate()
print("good job!")
