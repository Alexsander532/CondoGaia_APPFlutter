/// Service Locator para Injeção de Dependência
/// Usando GetIt para facilitar a gerência de dependências
///
/// Instale: flutter pub add get_it
/// Depois importe em main.dart e chame setupReservaDependencies()

// import 'package:get_it/get_it.dart';
//
// // Descomente quando tiver GetIt instalado

import '../../data/datasources/reserva_remote_datasource.dart';
import '../../data/models/reserva_model.dart';
import '../../data/repositories/reserva_repository_impl.dart';
import '../../domain/repositories/reserva_repository.dart';
import '../../domain/usecases/reserva_usecases.dart';
import '../cubit/reserva_cubit.dart';

/// Sem GetIt - Injeção Manual (mais verboso mas funciona sem dependências extras)
class ReservaDependencies {
  static ReservaCubit createReservaCubit() {
    // Data Layer
    final remoteDataSource = ReservaRemoteDataSourceImpl();
    final repository = ReservaRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    // Domain Layer - UseCases
    final obterReservasUseCase = ObterReservasUseCase(repository: repository);
    final obterAmbientesUseCase = ObterAmbientesUseCase(repository: repository);
    final criarReservaUseCase = CriarReservaUseCase(repository: repository);
    final cancelarReservaUseCase = CancelarReservaUseCase(
      repository: repository,
    );
    final validarDisponibilidadeUseCase = ValidarDisponibilidadeUseCase(
      repository: repository,
    );
    final atualizarReservaUseCase = AtualizarReservaUseCase(
      repository: repository,
    );

    // Presentation Layer - Cubit
    return ReservaCubit(
      obterReservasUseCase: obterReservasUseCase,
      obterAmbientesUseCase: obterAmbientesUseCase,
      criarReservaUseCase: criarReservaUseCase,
      cancelarReservaUseCase: cancelarReservaUseCase,
      validarDisponibilidadeUseCase: validarDisponibilidadeUseCase,
      atualizarReservaUseCase: atualizarReservaUseCase,
    );
  }
}

/// COM GetIt - Mais elegante e reutilizável
/// DESCOMENTE APÓS INSTALAR: flutter pub add get_it
///
// final getIt = GetIt.instance;
//
// void setupReservaDependencies() {
//   // Data Layer
//   getIt.registerSingleton<ReservaRemoteDataSource>(
//     ReservaRemoteDataSourceImpl(),
//   );
//
//   getIt.registerSingleton<ReservaRepository>(
//     ReservaRepositoryImpl(
//       remoteDataSource: getIt<ReservaRemoteDataSource>(),
//     ),
//   );
//
//   // Domain Layer - UseCases
//   getIt.registerSingleton(
//     ObterReservasUseCase(repository: getIt<ReservaRepository>()),
//   );
//   getIt.registerSingleton(
//     CriarReservaUseCase(repository: getIt<ReservaRepository>()),
//   );
//   getIt.registerSingleton(
//     CancelarReservaUseCase(repository: getIt<ReservaRepository>()),
//   );
//   getIt.registerSingleton(
//     ValidarDisponibilidadeUseCase(repository: getIt<ReservaRepository>()),
//   );
//
//   // Presentation Layer
//   getIt.registerSingleton(
//     ReservaCubit(
//       obterReservasUseCase: getIt(),
//       criarReservaUseCase: getIt(),
//       cancelarReservaUseCase: getIt(),
//       validarDisponibilidadeUseCase: getIt(),
//     ),
//   );
// }
//
// // Na tela:
// @override
// Widget build(BuildContext context) {
//   return BlocProvider(
//     create: (context) => getIt<ReservaCubit>(),
//     child: ReservaScreen(...),
//   );
// }
