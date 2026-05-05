#!/bin/bash
TOKEN=$(gh auth token)
echo "{\"Authorization\": \"Bearer $TOKEN\"}"
