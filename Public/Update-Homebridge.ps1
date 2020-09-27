function Update-Homebridge {
    param(

    )

    Invoke-Command {
        hb-service stop
        npm install -g homebridge@latest homebridge-config-ui-x@latest
        hb-service start
    }
}