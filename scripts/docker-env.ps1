# Dot-source this in PowerShell to get btc/alice/bob/carol shortcuts:
#   . ./scripts/docker-env.ps1
# Then run:  btc getblockchaininfo   alice getinfo   etc.

function btc {
    docker exec lab-bitcoind bitcoin-cli -rpcuser=clnrpc -rpcpassword=clrpcpass -rpcport=18443 -regtest @args
}

function alice {
    docker exec lab-cln-alice lightning-cli --lightning-dir=/root/.lightning @args
}

function bob {
    docker exec lab-cln-bob lightning-cli --lightning-dir=/root/.lightning @args
}

function carol {
    docker exec lab-cln-carol lightning-cli --lightning-dir=/root/.lightning @args
}

Write-Host "Docker CLN lab helpers loaded: btc, alice, bob, carol" -ForegroundColor Green
