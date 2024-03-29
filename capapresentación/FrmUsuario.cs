﻿using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using CapaNegocio;


namespace CapaPresentación
{
    public partial class FrmUsuario : Form
    {
        public FrmUsuario()
        {
            InitializeComponent();
        }

        private void button6_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void pictureBox8_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void FrmUsuario_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == (char)Keys.F5)
            {
                MessageBox.Show("Enter key pressed");
            }
            if (e.KeyChar == 13)
            {
                MessageBox.Show("Enter key pressed");
            }

        }

        private void FrmUsuario_KeyDown(object sender, KeyEventArgs e)
        {         
        }

        private void FrmUsuario_Load(object sender, EventArgs e)
        {
            this.txtNombre.Focus();
            
        }

        private void btnGuardar_Click(object sender, EventArgs e)
        {
            GuardarUSuario();
        }

        private void btnNuevo_Click(object sender, EventArgs e)
        {
            VaciarCampos();
            DataTable User = NUsuario.BuscarUser();
            DataRow row = User.Rows[0];
            txtNombre.Focus();
            comboEstado.Text = comboEstado.Items[0].ToString();
            comboTipoUsuario.Text = comboTipoUsuario.Items[0].ToString();
            txtIdUsuario.Text = row["Us_Id"].ToString();
            btnModificar.Enabled = false;
            btnEliminar.Enabled = false;
            btnBuscar.Enabled = false;

            
        }

        public void VaciarCampos()
        {
            foreach (Control ctrl in this.groupBox1.Controls)
            {
                if (ctrl is TextBox)
                {
                    TextBox text = ctrl as TextBox;
                    text.Clear();
                }
            }
        }

        private void btnModificar_Click(object sender, EventArgs e)
        {

        }

        private void pictureBox3_Click(object sender, EventArgs e)
        {

        }

        private void PictureBox7_Click(object sender, EventArgs e)
        {

        }

        private void TxtUsuario_KeyPress(object sender, KeyPressEventArgs e)
        {
           
        }

        private void TxtUsuario_TextChanged(object sender, EventArgs e)
        {

        }

        private void TxtContrasenha_TextChanged(object sender, EventArgs e)
        {

        }

        private void TxtUsuario_KeyUp(object sender, KeyEventArgs e)
        {

        }

        private void ComboTipoUsuario_KeyPress(object sender, KeyPressEventArgs e)
        {
            if (e.KeyChar == Convert.ToChar(Keys.Enter))
            {
                GuardarUSuario();
            }
        }

        private void GuardarUSuario()
        {
            int contador = 0;

            foreach (Control ctrl in this.groupBox1.Controls)
            {
                if (ctrl is TextBox)
                {
                    TextBox text = ctrl as TextBox;
                    

                    if (text.TextLength > 3)
                    {
                        contador++;

                    }
                    else
                    {
                        
                    }
                       
                    
                }
            }

            if (contador == 4)
            {
                try
                {
                    string rpta = "";

                    string Nombre = this.txtNombre.Text;
                    string NombreUsuario = this.txtUsuario.Text;
                    string password = this.txtContrasenha.Text;
                    string TipoUsuario = this.comboTipoUsuario.SelectedItem.ToString();
                    int EstadoUsuario = 1;

                    if (comboEstado.SelectedItem.ToString() == "HABILITADO")
                    {
                        EstadoUsuario = 1;
                    }
                    else
                    {
                        EstadoUsuario = 2;
                    }
                    byte[] salt = Cryptographic.GenerateSalt();
                    var hashedPassword = Cryptographic.HashPasswordWithSalt(Encoding.UTF8.GetBytes(password), salt);
                    rpta = NUsuario.Insertar(Nombre, NombreUsuario, salt, hashedPassword, EstadoUsuario, TipoUsuario);
                    MessageBox.Show("Usuario creado existosamente", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Information);

                }
                catch (Exception)
                {
                    MessageBox.Show("El usuario ya esta creado", "Alerta", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    /* throw; */
                }
            }
            else
            {
                MessageBox.Show("Existen campos no llenados, o incumplen el mínimo de 4 caracteres y máx 12", "Aviso", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
           

        }
        
        

        private void ComboTipoUsuario_Enter(object sender, EventArgs e)
        {
            txtContrasenha.Text = txtUsuario.Text;

        }

        private void TxtUsuario_Leave(object sender, EventArgs e)
        {
            comboTipoUsuario.Focus();
        }

        private void ComboTipoUsuario_Leave(object sender, EventArgs e)
        {

        }
    }
}
