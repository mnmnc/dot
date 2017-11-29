#!/bin/env sh

xbps-install pass gpg

gpg --gen-key

pass init '<pgp-identity-email>'

