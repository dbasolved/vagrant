#!/bin/sh

echo "-----------------------------------"
echo "Setting password for Root"
echo "-----------------------------------"

echo "Oracle1" | passwd root --stdin

echo "-----------------------------------"
echo "Setting password for Oracle"
echo "-----------------------------------"

echo "Oracle1" | passwd oracle --stdin