#!/usr/bin/env python

# Author: Serg Kolo
# Date: Jan 30,2016
# Purpose: A graphical utility for practicing
#          random arithmetic operations
# Written for: http://askubuntu.com/q/725287/295286

#    Copyright: Serg Kolo , 2016
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

import sys
import time
import random
from PyQt4 import QtGui


class mathApp(QtGui.QWidget):
   def __init__(self):
       super(mathApp,self).__init__()
       self.mainMenu()

   def mainMenu(self):
      self.setGeometry(300, 300, 400, 200)

      self.btn = QtGui.QPushButton("Let's begin",self)
      self.btn.move(20,150)
      self.btn.clicked.connect(self.askQuestions)

      self.lbl1 = QtGui.QLabel(self)
      self.lbl1.move(20,25)
      self.lbl1.setText("Numbers From")
      
      
      self.lbl2 = QtGui.QLabel(self)
      self.lbl2.move(20,55)
      self.lbl2.setText("Numbers To")

      self.lbl2 = QtGui.QLabel(self)
      self.lbl2.move(20,85)
      self.lbl2.setText("Repeat (seconds)")

      self.le1 = QtGui.QLineEdit(self)
      self.le1.move(150,20)

      self.le2 = QtGui.QLineEdit(self)
      self.le2.move(150,50)
 
      self.le3 = QtGui.QLineEdit(self)
      self.le3.move(150,80)

      self.lbl3 = QtGui.QLabel(self)
      self.lbl3.move(20,105)
      
      self.setWindowTitle('Random Integer Arithmetic')
      
      self.show()

   def askQuestions(self):
       rangeStart = int(self.le1.text())
       rangeEnd = int(self.le2.text())
       sleepTime = int(self.le3.text())
       done=False
       while not done:
          self.show()
          expression = self.generateOperation(rangeStart,rangeEnd)
          correctAnswer = eval(expression)

          prompt = QtGui.QInputDialog() 
          text,ok = prompt.getText(self,'TEST',expression) 
          if ok:
             if int(text) == correctAnswer:                
                self.showAnswer("CORRECT,YOU ROCK !")
             else :
                self.showAnswer("Nope");
          else:
              done=True

          if done==True:
              self.close()
          time.sleep(sleepTime)
      

   def generateOperation(self,start,end):
      a = random.randint(start,end)
      b = random.randint(start,end)
      oplist = ['+','-','/','*']
      op = oplist[random.randint(0,3)]
      expr = str(a) + op + str(b) + ''
      return expr

   def showAnswer(self,result):
       popup = QtGui.QMessageBox()
       popup.setText(result)
       popup.exec_()
   

def main():
   root = QtGui.QApplication(sys.argv)
   app = mathApp()
   sys.exit(root.exec_())

if __name__ == '__main__':
   main()
