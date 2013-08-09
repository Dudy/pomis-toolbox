Idee und Aufbau der Toolbox
===========================

Die Toolbox soll im Prinzip ein Baum mit editierbarem Text werden.  
Der Wurzelknoten ist die Idee selbst.  
Deren Kindknoten beschreiben Requirements.  
Deren Kindknoten beschreiben User Stories.  
Deren Kindknoten beschreiben Tasks.  

Etwa so:

    + Idee            Toolbox zum Entwickeln von Geschäftsideen
      + Requirement   Login Möglichkeit, jede Aktion soll einem Benutzer zugeordne...
        + User Story  Als Benutzer will ich mich mit Name/Passwort anmelden, damit...
          + Task      SignIn: neuer Benutzer meldet sich zum ersten Mal an
          + Task      LogIn: bestehender Benutzer meldet sich erneut an
        + User Story  Als Benutzer will ich mich mit einem Knopfdruck wieder abmel...
          + Task      LogOut: Button oder link rechts oben für Logout
      + Requirement   Datensammlung und -ansicht sollen hierarchisch aufgebaut sein
        + User Story  Als Anwender will ich einen Navigationsbaum links, um schnel...
          + Task      zweispaltiges Layout, NavTree links, NavTreeLinkedTable rechts
        + User Story  Als Anwender will ich zum Editieren einen Textbereich, um be...
          + Task      Eingabe: TextArea, groß, 10 Zeilen sichtbar, scrollbar
          + Task      Anzeige: TextField oder Label, erste 150 Zeichen, dann "..."

Im Augenblick stellt sich mir jetzt doch die Frage, warum ich nicht gleich Agilo for Trac benutze. Ich gebe mir momentan zwei Antworten:  
1. ist es irgendwie doch viel zu kompliziert am Anfang.  
2. brauche ich irgendwo einen Rootserver, um das Laufen zu lassen. Hab ich grad nicht, ich will das eigentlich auf Heroku oder Google App Engine laufen lassen.  

Außerdem fällt mir jetzt gerade auf, daß ich auch Github benutzen kann. Daran werden ich nachher arbeiten.

Ein Baum mit editierbarem Text ist aber ein bißchen aufwändig. Man könnte das mit Dynatree machen, ich versuche aber erst mal was mit weniger Aufwand und verschiebe das nach [Version 2](Version2). Die [Version 1](Version2) versuche ich erst mal nur mit plain HTML.
Die [Infrastruktur zur Entwicklung des Projekts ist hier](Infrastruktur_zur_Entwicklung_des_Projekts) beschrieben.