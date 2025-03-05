import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _emailVerificationSent = false;
  
  AuthService() {
    _initializeAuth();
  }
  
  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get emailVerificationSent => _emailVerificationSent;
  
  // Nuovo getter per ottenere il username in modo sicuro
  String? get username => _user?.userMetadata?['username'] as String? ?? 'Esploratore';
  
  // Initializza l'autenticazione controllando la sessione
  Future<void> _initializeAuth() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Controlla se c'è una sessione esistente
      final session = _supabase.auth.currentSession;
      
      if (session != null) {
        // Verifica che l'utente abbia confermato l'email
        if (session.user.emailConfirmedAt != null) {
          _user = session.user;
          debugPrint("Sessione esistente valida trovata per: ${_user?.email}");
        } else {
          // L'utente non ha confermato l'email, forza il logout
          debugPrint("Sessione trovata ma email non confermata, effettuo logout");
          await _supabase.auth.signOut();
          _user = null;
        }
      }
      
      // Ascolta i cambiamenti di autenticazione
      _supabase.auth.onAuthStateChange.listen((data) {
        final AuthChangeEvent event = data.event;
        final Session? session = data.session;
        
        debugPrint("Evento auth: $event");
        
        if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.userUpdated) {
          // Verifica che l'email sia confermata prima di considerare l'utente autenticato
          if (session?.user.emailConfirmedAt != null) {
            _user = session?.user;
            debugPrint("Utente autenticato con email confermata: ${_user?.email}");
          } else {
            _user = null;
            debugPrint("Login fallito: email non confermata");
          }
        } else if (event == AuthChangeEvent.signedOut) {
          _user = null;
          debugPrint("Utente disconnesso");
        }
        
        notifyListeners();
      });
    } catch (e) {
      _error = 'Errore durante l\'inizializzazione dell\'autenticazione: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Registrazione con email e password
  Future<void> signUp({required String email, required String password, String? username}) async {
    try {
      _isLoading = true;
      _error = null;
      _emailVerificationSent = false;
      notifyListeners();
      
      debugPrint("Tentativo di registrazione con email: $email");
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );
      
      if (response.user != null) {
        _user = response.user;
        _emailVerificationSent = true;
        debugPrint("Registrazione completata, verifica email necessaria per: ${_user?.email}");
      } else {
        _error = 'Errore durante la registrazione.';
        debugPrint("Registrazione fallita: nessun utente restituito");
      }
    } catch (e) {
      _error = 'Errore durante la registrazione: $e';
      debugPrint("Eccezione durante la registrazione: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Login con email e password
  Future<void> signIn({required String email, required String password}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      debugPrint("Tentativo di login con email: $email");
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        _user = response.user;
        debugPrint("Login completato con successo per: ${_user?.email}");
      } else {
        _error = 'Credenziali non valide.';
        debugPrint("Login fallito: nessun utente restituito");
      }
    } catch (e) {
      _error = 'Errore durante il login: $e';
      debugPrint("Eccezione durante il login: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Logout
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _supabase.auth.signOut();
      _user = null;
      debugPrint("Logout completato con successo");
    } catch (e) {
      _error = 'Errore durante il logout: $e';
      debugPrint("Eccezione durante il logout: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Reset password (invia email con link di reset)
  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _supabase.auth.resetPasswordForEmail(email);
      debugPrint("Email di reset password inviata a: $email");
    } catch (e) {
      _error = 'Errore nell\'invio dell\'email di reset password: $e';
      debugPrint("Eccezione durante il reset password: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Gestire il deep link per reset password
  Future<void> handleDeepLinkForPasswordReset(String deepLink) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint("Gestione deep link per reset password: $deepLink");
      
      final response = await _supabase.auth.getSessionFromUrl(Uri.parse(deepLink));

      _user = response.session.user;
      debugPrint("Sessione ottenuta da URL per: ${_user?.email}");
        } catch (e) {
      _error = 'Errore nel gestire il link di reset password: $e';
      debugPrint("Eccezione durante la gestione del deep link: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Gestire la verifica dell'email tramite deep link
  Future<void> setSessionFromDeepLink(String accessToken, String? refreshToken, String? type) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      debugPrint("Impostazione sessione da deep link, tipo: $type");
      
      if (accessToken.isNotEmpty) {
        try {
          await _supabase.auth.setSession(accessToken);
          _user = _supabase.auth.currentUser;
          debugPrint("Sessione impostata da deep link per: ${_user?.email}");
        } catch (e) {
          debugPrint("Errore nell'impostazione della sessione: $e");
          
          // Fallback: prova a ottenere la sessione corrente
          final session = _supabase.auth.currentSession;
          if (session != null) {
            _user = session.user;
            debugPrint("Usata sessione esistente per: ${_user?.email}");
          }
        }
      }
    } catch (e) {
      _error = 'Errore durante la verifica dell\'email: $e';
      debugPrint("Eccezione durante la verifica dell'email: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Metodo per completare il reset della password
  Future<void> completePasswordReset({required String newPassword}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Controlla se c'è una sessione attiva dopo il reset
      final session = _supabase.auth.currentSession;
      if (session == null) {
        _error = 'Sessione non trovata. Riprova a effettuare il login.';
        debugPrint("Reset password fallito: nessuna sessione");
        notifyListeners();
        return;
      }

      // Aggiorna la password con la nuova scelta dall'utente
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      _user = session.user;
      debugPrint("Reset password completato con successo per: ${_user?.email}");
    } catch (e) {
      _error = 'Errore nel completare il reset della password: $e';
      debugPrint("Eccezione durante il completamento del reset password: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Aggiorna profilo utente
  Future<void> updateProfile({String? username}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      if (username != null) {
        await _supabase.auth.updateUser(
          UserAttributes(
            data: {'username': username},
          ),
        );
        
        debugPrint("Profilo aggiornato con username: $username");
      }
      
      // Aggiorna l'utente con i nuovi dati
      _user = _supabase.auth.currentUser;
    } catch (e) {
      _error = 'Errore nell\'aggiornamento del profilo: $e';
      debugPrint("Eccezione durante l'aggiornamento del profilo: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Forza il logout
  Future<void> forceLogout() async {
    try {
      await _supabase.auth.signOut();
      _user = null;
      debugPrint("Logout forzato completato");
      notifyListeners();
    } catch (e) {
      debugPrint("Errore durante il logout forzato: $e");
    }
  }
}