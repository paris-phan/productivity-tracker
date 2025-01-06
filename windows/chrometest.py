from pywinauto import Application # pip install pywinauto

app = Application(backend='uia')

app.connect(title_re=".*Chrome.*")

element_name="Address and search bar"

dlg = app.top_window()

url = dlg.child_window(title=element_name, control_type="Edit").get_value()

