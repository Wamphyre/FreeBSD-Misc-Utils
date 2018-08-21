#!/bin/bash

pkg update && pkg upgrade -y;

portsnap fetch auto;

pkg clean -y;

pkg autoremove -y;
