namespace TURBU.RM2k3.RTPConverter

partial class MainForm(System.Windows.Forms.Form):
	private components as System.ComponentModel.IContainer = null
	
	protected override def Dispose(disposing as bool) as void:
		if disposing:
			if components is not null:
				components.Dispose()
		super(disposing)
	
	// This method is required for Windows Forms designer support.
	// Do not change the method contents inside the source code editor. The Forms designer might
	// not be able to load this method if it was changed manually.
	private def InitializeComponent():
		self.btnRMProject = System.Windows.Forms.Button()
		self.label1 = System.Windows.Forms.Label()
		self.txtRMProject = System.Windows.Forms.TextBox()
		self.btnConvert = System.Windows.Forms.Button()
		self.dlgRMLocation = System.Windows.Forms.OpenFileDialog()
		self.lblReport = System.Windows.Forms.Label()
		self.SuspendLayout()
		# 
		# btnRMProject
		# 
		self.btnRMProject.Anchor = cast(System.Windows.Forms.AnchorStyles,(System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right))
		self.btnRMProject.Font = System.Drawing.Font("Microsoft Sans Serif", 7.8, System.Drawing.FontStyle.Bold, System.Drawing.GraphicsUnit.Point, cast(System.Byte,0))
		self.btnRMProject.Location = System.Drawing.Point(605, 36)
		self.btnRMProject.Name = "btnRMProject"
		self.btnRMProject.Size = System.Drawing.Size(33, 23)
		self.btnRMProject.TabIndex = 6
		self.btnRMProject.Text = "..."
		self.btnRMProject.TextAlign = System.Drawing.ContentAlignment.TopCenter
		self.btnRMProject.UseVisualStyleBackColor = true
		self.btnRMProject.Click += self.BtnRMProjectClick as System.EventHandler
		# 
		# label1
		# 
		self.label1.Location = System.Drawing.Point(26, 39)
		self.label1.Name = "label1"
		self.label1.Size = System.Drawing.Size(246, 23)
		self.label1.TabIndex = 7
		self.label1.Text = "RPG Maker Project Database:"
		# 
		# lblReport
		# 
		self.lblReport.Location = System.Drawing.Point(26, 80)
		self.lblReport.Name = "label1"
		self.lblReport.Size = System.Drawing.Size(446, 23)
		self.lblReport.Text = ""
		# 
		# txtRMProject
		# 
		self.txtRMProject.Anchor = cast(System.Windows.Forms.AnchorStyles,(System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Right))
		self.txtRMProject.Location = System.Drawing.Point(238, 36)
		self.txtRMProject.Name = "txtRMProject"
		self.txtRMProject.ReadOnly = true
		self.txtRMProject.Size = System.Drawing.Size(356, 22)
		self.txtRMProject.TabIndex = 5
		# 
		# btnConvert
		# 
		self.btnConvert.Location = System.Drawing.Point(232, 103)
		self.btnConvert.Name = "btnConvert"
		self.btnConvert.Size = System.Drawing.Size(75, 23)
		self.btnConvert.TabIndex = 8
		self.btnConvert.Text = "&Convert"
		self.btnConvert.UseVisualStyleBackColor = true
		self.btnConvert.Enabled = false
		self.btnConvert.Click += self.BtnConvertClick as System.EventHandler
		# 
		# dlgRMLocation
		# 
		self.dlgRMLocation.FileName = "RPG_RT.ldb"
		self.dlgRMLocation.Filter = "RPG Maker Database (*.ldb) | *.ldb"
		# 
		# MainForm
		# 
		self.AutoScaleDimensions = System.Drawing.SizeF(8, 16)
		self.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
		self.ClientSize = System.Drawing.Size(682, 164)
		self.Controls.Add(self.btnConvert)
		self.Controls.Add(self.btnRMProject)
		self.Controls.Add(self.label1)
		self.Controls.Add(self.txtRMProject)
		self.Name = "MainForm"
		self.Text = "RTP Converter"
		self.ResumeLayout(false)
		self.PerformLayout()
	private dlgRMLocation as System.Windows.Forms.OpenFileDialog
	private btnConvert as System.Windows.Forms.Button
	private txtRMProject as System.Windows.Forms.TextBox
	private label1 as System.Windows.Forms.Label
	private btnRMProject as System.Windows.Forms.Button
	private lblReport as System.Windows.Forms.Label

