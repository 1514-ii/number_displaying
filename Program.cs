using Microsoft.Win32;
using System.Drawing;
using System.Windows.Forms;

internal static class Program
{
    [STAThread]
    static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new OverlayForm());
    }
}

internal sealed class OverlayForm : Form
{
    private const string RunKeyPath = @"Software\Microsoft\Windows\CurrentVersion\Run";
    private const string AppName = "NumberOverlay";

    private readonly Label _numberLabel;
    private readonly string _configPath;

    public OverlayForm()
    {
        FormBorderStyle = FormBorderStyle.None;
        StartPosition = FormStartPosition.Manual;
        Location = new Point(0, 0);
        BackColor = Color.Black;
        ForeColor = Color.Lime;
        TopMost = true;
        ShowInTaskbar = false;
        AutoSize = true;
        AutoSizeMode = AutoSizeMode.GrowAndShrink;

        _numberLabel = new Label
        {
            AutoSize = true,
            Font = new Font("Segoe UI", 42, FontStyle.Bold),
            BackColor = Color.Black,
            ForeColor = Color.Lime,
            Padding = new Padding(8, 0, 8, 0)
        };

        Controls.Add(_numberLabel);

        _configPath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
            "NumberOverlay",
            "number.txt");

        EnsureStartupRegistration();
        _numberLabel.Text = LoadNumber();

        var menu = new ContextMenuStrip();
        menu.Items.Add("숫자 변경", null, (_, _) => ChangeNumber());
        menu.Items.Add("종료", null, (_, _) => Close());
        ContextMenuStrip = menu;

        MouseClick += (_, e) =>
        {
            if (e.Button == MouseButtons.Right)
                ContextMenuStrip?.Show(this, e.Location);
        };

        _numberLabel.MouseClick += (_, e) =>
        {
            if (e.Button == MouseButtons.Left)
                ChangeNumber();
        };
    }

    private void EnsureStartupRegistration()
    {
        using var key = Registry.CurrentUser.OpenSubKey(RunKeyPath, true)
            ?? Registry.CurrentUser.CreateSubKey(RunKeyPath);

        string exePath = Application.ExecutablePath;
        key?.SetValue(AppName, $"\"{exePath}\"");
    }

    private string LoadNumber()
    {
        var dir = Path.GetDirectoryName(_configPath)!;
        Directory.CreateDirectory(dir);

        if (!File.Exists(_configPath))
        {
            File.WriteAllText(_configPath, "0");
            return "0";
        }

        var value = File.ReadAllText(_configPath).Trim();
        return string.IsNullOrWhiteSpace(value) ? "0" : value;
    }

    private void SaveNumber(string value)
    {
        File.WriteAllText(_configPath, value);
        _numberLabel.Text = value;
    }

    private void ChangeNumber()
    {
        var current = _numberLabel.Text;
        var input = Microsoft.VisualBasic.Interaction.InputBox(
            "화면에 표시할 숫자를 입력하세요.",
            "숫자 변경",
            current);

        if (!string.IsNullOrWhiteSpace(input))
            SaveNumber(input.Trim());
    }
}
