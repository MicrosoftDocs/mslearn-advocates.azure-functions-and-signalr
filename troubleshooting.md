# Troubleshooting

Log an issue and @mention the [`javascript-docs`](https://github.com/orgs/MicrosoftDocs/teams/javascript-docs) team. 

### GitHub Actions workflows troubleshooting

* If the server doesn't build correctly, add debugging to make sure the package path is correct.

  ```yml
        - name: Echo package path
        run: echo ${{ env.PACKAGE_PATH }}
  ```

  The value should be: `start/server`. You can also use `solution/server`. 

* If the client doesn't deploy correctly, add debugging to make sure it is build with the **BACKEND_URL**. 

  ```yml
        - name: Echo BACKEND_URL variable
        run: echo ${{ variables.BACKEND_URL }}
  ```

### Codespaces troubleshooting

* If the request from the client is refused by the serverless app, and you have CORS correctly configured in `local.settings.json`, change the visibility of the 7071 port from `private` to `public` for testing purposes only. This should allow the client to find the server in Codspaces. 
