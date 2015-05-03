namespace TURBU.RM2k3.RTPConverter

import System
import System.IO
import System.Linq.Enumerable
import System.Windows.Forms

partial class MainForm:
	private _projectPath as string
	private _maps as (string)
	
	public def constructor():
		// The InitializeComponent() call is required for Windows Forms designer support.
		InitializeComponent()
	
	private def ValidatePaths():
		btnConvert.Enabled = \
			(not string.IsNullOrEmpty(txtRMProject.Text)) and System.IO.File.Exists(txtRMProject.Text)
	
	private def BtnRMProjectClick(sender as object, e as System.EventArgs):
		if dlgRMLocation.ShowDialog() == DialogResult.OK:
			self.txtRMProject.Text = dlgRMLocation.FileName
		ValidatePaths()
	
	private def BackupProject():
		backupFolder = Path.Combine(_projectPath, 'Backup')
		Directory.CreateDirectory(backupFolder)
		File.Copy(Path.Combine(_projectPath, 'RPG_RT.ldb'), Path.Combine(backupFolder, 'RPG_RT.ldb'), true)
		File.Copy(Path.Combine(_projectPath, 'RPG_RT.lmt'), Path.Combine(backupFolder, 'RPG_RT.lmt'), true)
		for filename in _maps:
			File.Copy(filename, Path.Combine(backupFolder, Path.GetFileName(filename)), true)
	
	private def BtnConvertClick(sender as object, e as System.EventArgs):
		_projectPath = Path.GetDirectoryName(txtRMProject.Text)
		_maps = Directory.EnumerateFiles(_projectPath, '*.lmu').ToArray()
		btnConvert.Enabled = false
		BackupProject()
		scanner = ProjectScanner({name| self.Invoke({lblReport.Text = "Scanning $name"})})
		thread = System.Threading.Thread() do ():
			scanner.Convert(_projectPath, _maps)
			finish = do():
				if scanner.Logs.Count == 0:
					message = 'No RTP references found'
				else:
					message = "Found and converted $(scanner.Logs.Count) RTP references.  Details saved as 'RTP Converter.log'"
					File.WriteAllLines(Path.Combine(_projectPath, 'RTP Converter.log'), scanner.Logs.ToArray())
				MessageBox.Show(message, "Conversion complete")
				btnConvert.Enabled = true
			self.Invoke(finish)
		thread.Start()
		

[STAThread]
public def Main(argv as (string)) as void:
	Application.EnableVisualStyles()
	Application.SetCompatibleTextRenderingDefault(false)
	Application.Run(MainForm())

