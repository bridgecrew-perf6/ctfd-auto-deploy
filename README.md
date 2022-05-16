# CTFd auto deploy script

- CTFd version: 3.5.0 (https://github.com/CTFd/CTFd)
- Integrate ctfd-whale plugin (https://github.com/frankli0324/ctfd-whale)
- Integrate ctfd-plugin-multichoice plugin (https://github.com/liuxin2020/ctfd-plugin-multichoice)

## Use
```
bash <(curl -s https://raw.githubusercontent.com/pwnthebox/ctfd-auto-deploy/master/install.sh)
```

## Parameter description
```
  Enter node domain [127.0.0.1.nip.io]: example.com    # whale http mode domain, set *.example.com resolution in dns server
  Enter node http mode port [8080]:                    # whale http mode port （do not use 80)
  Enter node direct mode port range [10000-10100]:     # whale direct mode port
```
