//    Openbravo POS is a point of sales application designed for touch screens.
//    Copyright (C) 2007 Openbravo, S.L.
//    http://www.openbravo.com/product/pos
//
//    This file is part of Openbravo POS.
//
//    Openbravo POS is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    Openbravo POS is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with Openbravo POS.  If not, see <http://www.gnu.org/licenses/>.

package com.openbravo.pos.reports;

import com.openbravo.basic.BasicException;
import com.openbravo.data.gui.ComboBoxValModel;
import com.openbravo.data.loader.Datas;
import com.openbravo.data.loader.QBFCompareEnum;
import com.openbravo.data.loader.SerializerWrite;
import com.openbravo.data.loader.SerializerWriteBasic;
import com.openbravo.pos.forms.AppLocal;
import com.openbravo.pos.forms.AppView;
import com.openbravo.pos.inventory.MovementReason;
import java.awt.Component;

public class JParamsReason extends javax.swing.JPanel implements ReportEditorCreator {
    
    private ComboBoxValModel m_ReasonModel;
    
    /** Creates new form JParamsReason */
    public JParamsReason() {
        initComponents();
        
        m_ReasonModel = new ComboBoxValModel();
        m_ReasonModel.add(null);
        m_ReasonModel.add(MovementReason.IN_PURCHASE);
        m_ReasonModel.add(MovementReason.IN_REFUND);
        m_ReasonModel.add(MovementReason.IN_MOVEMENT);
        m_ReasonModel.add(MovementReason.OUT_SALE);
        m_ReasonModel.add(MovementReason.OUT_REFUND);
        m_ReasonModel.add(MovementReason.OUT_BREAK);
        m_ReasonModel.add(MovementReason.OUT_MOVEMENT);
        
        m_jreason.setModel(m_ReasonModel);
        // m_jreason.setSelectedItem(null);
    }
    
    public void init(AppView app) {
    }

    public void activate() throws BasicException {
    }

    public SerializerWrite getSerializerWrite() {
        return new SerializerWriteBasic(new Datas[] {Datas.OBJECT, Datas.INT});
    }

    public Component getComponent() {
        return this;
    }
    
    public Object createValue() throws BasicException {
        
        return new Object[] {
            m_ReasonModel.getSelectedItem() == null ? QBFCompareEnum.COMP_NONE : QBFCompareEnum.COMP_EQUALS, m_ReasonModel.getSelectedKey()
        };
    }
    
    /** This method is called from within the constructor to
     * initialize the form.
     * WARNING: Do NOT modify this code. The content of this method is
     * always regenerated by the Form Editor.
     */
    // <editor-fold defaultstate="collapsed" desc=" Generated Code ">//GEN-BEGIN:initComponents
    private void initComponents() {
        jLabel2 = new javax.swing.JLabel();
        m_jreason = new javax.swing.JComboBox();

        setLayout(null);

        setBorder(javax.swing.BorderFactory.createTitledBorder(AppLocal.getIntString("label.byreason")));
        setPreferredSize(new java.awt.Dimension(400, 60));
        jLabel2.setText(AppLocal.getIntString("label.stockreason"));
        add(jLabel2);
        jLabel2.setBounds(20, 20, 100, 14);

        add(m_jreason);
        m_jreason.setBounds(150, 20, 220, 20);

    }// </editor-fold>//GEN-END:initComponents
    
    
    // Variables declaration - do not modify//GEN-BEGIN:variables
    private javax.swing.JLabel jLabel2;
    private javax.swing.JComboBox m_jreason;
    // End of variables declaration//GEN-END:variables
    
}
