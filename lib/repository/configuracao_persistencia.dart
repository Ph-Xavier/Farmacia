// enum usado para representar as opções de persistência do app.
//
// local        → usa apenas sqlite.
// remota       → usa apenas api.
// offlineFirst → tenta usar api, mas salva localmente se estiver offline.
enum OrigemPersistencia { local, remota, offlineFirst }

class ConfiguracaoPersistencia {
  // o app usa o modo offlineFirst.
  //
  // ele tentará salvar na api.
  // se não conseguir, salvará localmente como pendente.
  static const OrigemPersistencia origem = OrigemPersistencia.offlineFirst;
}
