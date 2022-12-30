az ad app create --display-name 'Atea-ConditionalAccess'

az ad app list --display-name 'Atea-ConditionalAccess'
az ad app show --id 'b3ebb504-2372-4946-9927-2f04022757d0'

az ad app credential reset --id 'b3ebb504-2372-4946-9927-2f04022757d0' --append --credential-description 'Atea-CondAccess'

# Graph API                                 - 00000003-0000-0000-c000-000000000000
# Application.Read.All                      - 9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30
# Directory.ReadWrite.All                   - 19dbc75e-c2e2-444c-a770-ec69d8559fc7
# Policy.Read.All                           - 246dd0d5-5bd0-4def-940b-0421030a5b68
# Policy.ReadWrite.ApplicationConfiguration - be74164b-cff1-491c-8741-e671cb536e13
# Policy.ReadWrite.ConditionalAccess        - 01c0a623-fc9b-48e9-b794-0756f8e8f067
az ad app permission add --id b3ebb504-2372-4946-9927-2f04022757d0 --api 00000003-0000-0000-c000-000000000000 --api-permissions 9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30=Role
az ad app permission add --id b3ebb504-2372-4946-9927-2f04022757d0 --api 00000003-0000-0000-c000-000000000000 --api-permissions 19dbc75e-c2e2-444c-a770-ec69d8559fc7=Role
az ad app permission add --id b3ebb504-2372-4946-9927-2f04022757d0 --api 00000003-0000-0000-c000-000000000000 --api-permissions 246dd0d5-5bd0-4def-940b-0421030a5b68=Role
az ad app permission add --id b3ebb504-2372-4946-9927-2f04022757d0 --api 00000003-0000-0000-c000-000000000000 --api-permissions be74164b-cff1-491c-8741-e671cb536e13=Role
az ad app permission add --id b3ebb504-2372-4946-9927-2f04022757d0 --api 00000003-0000-0000-c000-000000000000 --api-permissions 01c0a623-fc9b-48e9-b794-0756f8e8f067=Role
az ad app permission admin-consent --id b3ebb504-2372-4946-9927-2f04022757d0

