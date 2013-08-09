#!/bin/bash

# nur den development branch aus beta klonen, und die Herkunftsbezeichnung soll auch beta sein
git clone ./beta/ -o beta -b development --single-branch ./alpha
# ins alpha repository wechseln
cd alpha
# den development branch in master umbenennen
git branch -m development master