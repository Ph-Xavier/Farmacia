# Roteiro de testes — Farmacia

Roteiro para validar os três cenários obrigatórios do 2º bimestre.
Execute os testes em um dispositivo/emulador Android ou iOS, pois o `sqflite`
não funciona no navegador.

## Preparação

1. Verifique se a API está no ar:

   ```bash
   curl https://bank-api-t311.onrender.com/teste-banco
   curl https://bank-api-t311.onrender.com/vendas
   ```

   Se `/vendas` retornar 404, faça o deploy manual no Render
   (**Manual Deploy → Deploy latest commit**) e aguarde o status **Live**.

2. Se as tabelas ainda não existirem, acesse uma vez:

   ```bash
   curl https://bank-api-t311.onrender.com/criar-tabelas
   ```

3. Instale as dependências e rode o app:

   ```bash
   flutter pub get
   flutter run
   ```

## Teste 1 — API funcionando

1. Abra o app.
2. Toque em **Vendas**.
3. Toque no botão **+**.
4. Informe um cupom e um valor, por exemplo `1234` e `25,50`.
5. Toque em **Confirmar**.
6. Confirme a mensagem “Venda salva com sucesso”.
7. Confirme que a venda aparece na lista.
8. No dashboard, confirme que o contador de pendentes permanece em zero.
9. Consulte a API:

   ```bash
   curl https://bank-api-t311.onrender.com/vendas
   ```

10. Confirme que a venda está no JSON retornado.

**Resultado esperado:** venda salva no SQLite como sincronizada e presente no
PostgreSQL.

## Teste 2 — API indisponível

1. Feche o aplicativo.
2. Execute apontando para uma URL inválida:

   ```bash
   flutter run --dart-define=API_BASE_URL=https://api-invalida.invalid
   ```

3. Toque em **Vendas** e cadastre outra venda, por exemplo cupom `5678` e
   valor `10,00`.
4. Confirme a mensagem “Venda salva com sucesso”.
5. Volte ao dashboard.
6. Confirme o texto com **1 registro pendente de sincronização**.
7. Abra novamente a lista de vendas.
8. Confirme que a venda pendente aparece na lista.

**Resultado esperado:** o cadastro não foi perdido; foi salvo no SQLite com
`sincronizado = 0` e aparece no app mesmo sem API.

## Teste 3 — Restaurar a API e sincronizar

1. Feche o aplicativo.
2. Execute novamente com a URL correta:

   ```bash
   flutter run
   ```

3. No dashboard, confirme que a venda pendente continua contabilizada.
4. Toque em **Sincronizar pendentes**.
5. Confirme a mensagem “Sincronização concluída com sucesso”.
6. Confirme que o contador foi para zero.
7. Consulte a API:

   ```bash
   curl https://bank-api-t311.onrender.com/vendas
   ```

8. Confirme que a venda do Teste 2 agora está no PostgreSQL.

**Resultado esperado:** o registro local foi marcado como sincronizado e está
disponível remotamente.

## Evidências para o vídeo

Sugestão de sequência para o vídeo obrigatório:

1. Mostrar o README e a arquitetura do projeto.
2. Mostrar a API publicada (`/teste-banco`, `/vendas`).
3. Executar o Teste 1.
4. Executar o Teste 2 com a URL inválida.
5. Mostrar o contador de pendentes.
6. Executar o Teste 3 e mostrar o registro no PostgreSQL.
