Amplify Gen1 で バックエンドに既に定義済みの GraphQL API を使いつつ、特定のオペレーションのみを生成 する方法を詳しく説明します。

デフォルトの問題点

amplify codegen を実行すると、バックエンドの GraphQL スキーマ全体 に基づいてクエリ・ミューテーション・サブスクリプションが自動生成されます。しかし、特定の API だけを利用したい場合、不要なオペレーションも生成されてしまう ことが問題です。

特定の API のみを生成する方法

1. 使用可能な API を確認

まず、Amplify に登録されている GraphQL API を確認します。

amplify status

ここで、目的の API の名前 (<API_NAME>) を確認してください。

2. API の GraphQL スキーマを取得

すでに定義されている GraphQL スキーマのパスを確認し、それを元にコードを生成します。

cat amplify/backend/api/<API_NAME>/build/schema.graphql

ここに、バックエンドに定義された全 GraphQL API が記述されています。

3. 特定の API のみを選択

特定の API のみを使用したい場合、.graphqlconfig.yml を編集して、生成対象のオペレーションを制限します。

amplify/.graphqlconfig.yml を編集

schemaPath: amplify/backend/api/<API_NAME>/build/schema.graphql
includes:
  - amplify/graphql/**/*.graphql  # ここで手動で追加したファイルのみ使用
excludes:
  - amplify/backend/api/<API_NAME>/build/**/*.graphql  # これでデフォルトの全自動生成を無効化

4. 使いたいオペレーションのみ .graphql に記述

Amplify の自動生成を使わず、バックエンドに定義された特定のクエリやミューテーションのみを .graphql ファイルとして作成 します。

例: amplify/graphql/GetUser.graphql

query GetUser($id: ID!) {
  getUser(id: $id) {
    id
    name
    email
  }
}

例: amplify/graphql/UpdateUser.graphql

mutation UpdateUser($input: UpdateUserInput!) {
  updateUser(input: $input) {
    id
    name
    email
  }
}

5. amplify codegen を実行

設定が正しく行われていれば、以下のコマンドを実行すると、amplify/graphql/ にあるオペレーションのみが Swift コードとして生成されます。

amplify codegen

このコマンドの実行後、amplify/generated/graphql/ に以下のようなファイルが作成されることを確認してください。

✅ GetUserQuery.swift
✅ UpdateUserMutation.swift
❌ 不要なクエリ・ミューテーションが含まれていないことを確認

6. iOS アプリで API を利用

生成されたオペレーションを iOS アプリ内で使用します。

ユーザー情報を取得

import Amplify

func fetchUser(id: String) async {
    let request = GraphQLRequest<GetUserQuery.Data>(
        document: GetUserQuery.operationString,
        variables: ["id": id]
    )
    do {
        let response = try await Amplify.API.query(request: request)
        print(response)
    } catch {
        print("Error fetching user: \(error)")
    }
}

ユーザー情報を更新

import Amplify

func updateUser(id: String, name: String, email: String) async {
    let request = GraphQLRequest<UpdateUserMutation.Data>(
        document: UpdateUserMutation.operationString,
        variables: ["input": ["id": id, "name": name, "email": email]]
    )
    do {
        let response = try await Amplify.API.mutate(request: request)
        print(response)
    } catch {
        print("Error updating user: \(error)")
    }
}

まとめ
	1.	amplify status で使用可能な GraphQL API を確認
	2.	amplify/backend/api/<API_NAME>/build/schema.graphql からバックエンドのスキーマを取得
	3.	.graphqlconfig.yml を編集して 特定のオペレーションのみを生成
	4.	amplify/graphql/ に 必要なクエリ・ミューテーションのみを記述
	5.	amplify codegen を実行し、特定の API のみを Swift コードに反映

この方法で、バックエンドの定義済み API を利用しつつ、不要なオペレーションを除外 できます！