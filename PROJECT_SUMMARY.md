# Project Summary: surprisebuildweb2

## Overview

`surprisebuildweb2` is a Clojure web application built using the [Kit framework](https://kit-clj.github.io/). It provides a foundation for building web services with API endpoints and HTML page serving capabilities. The project follows a modular architecture using Integrant for dependency injection and component lifecycle management.

## Key Architecture Components

### Web Stack
- **Framework**: Kit-clj (Clojure web framework)
- **Routing**: Reitit for HTTP routing with middleware support
- **Server**: Undertow embedded server
- **Templating**: Selmer templating engine for HTML rendering
- **Data Formats**: Muuntaja for request/response data transformation
- **Session Management**: Ring TTL sessions with configurable security

### Core Technologies
- **Language**: Clojure 1.12.0
- **Frontend**: ClojureScript with Reagent for React-based UI components
- **Build Tools**: tools.deps with aliases for different environments, Shadow-CLJS for ClojureScript compilation
- **Testing**: Cognitect test-runner with Peridot for integration tests
- **Development**: Integrant REPL for interactive development

## Project Structure

```
/
├── src/clj/surprisebuild/surprisebuildweb2/     # Main application code
│   ├── core.clj                                # Application entry point
│   ├── config.clj                              # Configuration management
│   └── web/                                    # Web layer
│       ├── handler.clj                         # Ring handler setup
│       ├── controllers/                        # Request handlers
│       │   └── health.clj                      # Health check endpoint
│       ├── middleware/                         # HTTP middleware
│       │   ├── core.clj                        # Middleware composition
│       │   ├── exception.clj                   # Exception handling
│       │   └── formats.clj                     # Data format handling
│       ├── pages/                              # HTML page rendering
│       │   └── layout.clj                      # Page layout templates
│       └── routes/                             # Route definitions
│           ├── api.clj                         # API routes
│           ├── pages.clj                       # HTML page routes
│           └── utils.clj                       # Routing utilities
├── src/cljs/surprisebuild/surprisebuildweb2/   # ClojureScript frontend code
│   └── core.cljs                               # Main ClojureScript entry point
├── env/                                        # Environment-specific config
│   ├── dev/                                    # Development configuration
│   ├── prod/                                   # Production configuration
│   └── test/                                   # Test configuration
├── resources/                                  # Static resources and config
│   ├── system.edn                              # System configuration
│   ├── html/                                   # HTML templates
│   └── public/                                 # Static web assets
├── test/                                       # Test files
├── shadow-cljs.edn                             # ClojureScript build configuration
├── package.json                                # Node.js dependencies
└── modules/                                    # Kit modules
    └── kit-modules/                            # Git submodule for kit modules
```

## Key Files and Their Purpose

### Core Application Files
- **`src/clj/surprisebuild/surprisebuildweb2/core.clj`**: Main entry point with system lifecycle management
- **`src/clj/surprisebuild/surprisebuildweb2/config.clj`**: Configuration loading and system setup
- **`resources/system.edn`**: Integrant system configuration defining components and dependencies

### Frontend Files
- **`src/cljs/surprisebuild/surprisebuildweb2/core.cljs`**: ClojureScript entry point with Reagent components
- **`shadow-cljs.edn`**: ClojureScript build configuration for Shadow-CLJS
- **`package.json`**: Node.js dependencies (React, React-DOM, Shadow-CLJS)
- **`resources/html/home.html`**: Main HTML template with React mount point

### Web Layer Files
- **`src/clj/surprisebuild/surprisebuildweb2/web/handler.clj`**: Ring handler and routing setup
- **`src/clj/surprisebuild/surprisebuildweb2/web/routes/api.clj`**: API endpoint definitions
- **`src/clj/surprisebuild/surprisebuildweb2/web/routes/pages.clj`**: HTML page route definitions
- **`src/clj/surprisebuild/surprisebuildweb2/web/controllers/health.clj`**: Health check controller

### Configuration Files
- **`deps.edn`**: Dependencies and development aliases
- **`kit.edn`**: Kit framework configuration
- **`bb.edn`**: Babashka task definitions for common operations
- **`Makefile`**: Build and development commands

## Dependencies and Versions

### Core Dependencies
- `org.clojure/clojure` 1.12.0 - Core Clojure language
- `metosin/reitit` 0.8.0 - HTTP routing library
- `ring/ring-core` 1.14.0 - HTTP abstraction library
- `io.github.kit-clj/kit-core` 1.0.9 - Kit framework core
- `io.github.kit-clj/kit-undertow` 1.0.8 - Undertow server integration
- `selmer/selmer` 1.12.50 - Templating engine
- `ch.qos.logback/logback-classic` 1.5.16 - Logging implementation

### Frontend Dependencies
- `reagent` 1.1.0 - React wrapper for ClojureScript
- `cljs-ajax` 0.8.4 - Ajax library for ClojureScript
- `react` 17.0.2 - React library
- `react-dom` 17.0.2 - React DOM library
- `shadow-cljs` 2.18.0 - ClojureScript build tool

### Development Dependencies
- `integrant/repl` 0.3.3 - REPL-based development workflow
- `ring/ring-devel` 1.14.0 - Development middleware
- `ring/ring-mock` 0.4.0 - Request mocking for tests
- `io.github.kit-clj/kit-generator` 0.2.5 - Code generation tools
- `nrepl/nrepl` 1.3.1 - Network REPL for development
- `cider/cider-nrepl` 0.45.0 - CIDER middleware for Emacs integration

## Available Commands and APIs

### Development Commands
```bash
# Start development server
make run                    # or clj -M:dev
make repl                   # Start REPL with nREPL
make test                   # Run tests
make uberjar                # Build production JAR

# Babashka tasks
bb run                      # Start development server
bb nrepl                    # Start nREPL server (port 7888)
bb cider                    # Start CIDER-compatible REPL
bb test                     # Run tests
bb uberjar                  # Build uberjar
bb format                   # Format code with cljstyle

# ClojureScript development
npx shadow-cljs watch app   # Start ClojureScript dev server
npx shadow-cljs compile app # Compile ClojureScript for production
npx shadow-cljs repl app    # Start ClojureScript REPL
```

### Available Endpoints
- **GET /api/health** - Health check endpoint returning system status
- **GET /** - Home page (HTML)
- **GET /api/** - API routes with Swagger documentation

### REPL Usage
```clojure
;; Start the system
(go)

;; Reload changes
(reset)

;; Stop the system
(stop-app)
```

## System Configuration

The application uses Integrant for component lifecycle management. Key system components defined in `resources/system.edn`:

- **`:system/env`** - Environment configuration (dev/test/prod)
- **`:server/http`** - HTTP server configuration (port 3000 by default)
- **`:handler/ring`** - Ring handler with middleware stack
- **`:router/core`** - Main router with route composition
- **`:reitit.routes/api`** - API route definitions
- **`:reitit.routes/pages`** - Page route definitions

### ClojureScript Build Configuration

Shadow-CLJS configuration in `shadow-cljs.edn`:
- **Build target**: Browser application
- **Output directory**: `target/classes/cljsbuild/public/js`
- **Asset path**: `/js` (served from resources/public)
- **Main module**: `app` with entry point `surprisebuild.surprisebuildweb2.core/init!`
- **Development**: Hot reloading with `mount-root` function
- **nREPL port**: 7002 for ClojureScript REPL

## Implementation Patterns

### Component Architecture
- Uses Integrant for dependency injection and component lifecycle
- Components are defined as multimethods implementing `ig/init-key` and `ig/halt-key!`
- System configuration is declarative in EDN format

### Request Handling
- Reitit router with data-driven route definitions
- Middleware applied at route and handler levels
- Controllers follow simple request → response pattern
- Data coercion using Malli schemas

### Development Workflow
- REPL-driven development with hot reloading
- Environment-specific configuration overlays
- Integrated testing with ring-mock

## Extension Points

### Adding New Routes
1. Define routes in appropriate namespace (`routes/api.clj` or `routes/pages.clj`)
2. Add controllers in `controllers/` directory
3. Routes are automatically discovered via Integrant system

### Adding New Middleware
1. Create middleware functions in `middleware/` directory
2. Compose middleware in `middleware/core.clj`
3. Apply to specific routes or globally

### Adding New Components
1. Define Integrant init/halt methods for new components
2. Add component configuration to `resources/system.edn`
3. Reference components using `#ig/ref` in system configuration

### Kit Modules
The project supports Kit modules for extending functionality:
- Installed modules tracked in `modules/install-log.edn`
- Currently has `:kit/html` module installed
- Additional modules available for databases, authentication, etc.

## Development Recommendations

1. **Start with REPL**: Use `make repl` or `bb nrepl` for interactive development
2. **Use `(go)` and `(reset)`**: Standard workflow for starting and reloading the system
3. **Follow Ring patterns**: Keep handlers pure functions returning Ring response maps
4. **Leverage Integrant**: Use component lifecycle for managing stateful resources
5. **Add tests**: Use Peridot for integration tests, standard clojure.test for unit tests
6. **Configure environment**: Use environment variables for configuration overrides
7. **Frontend development**: Use `npx shadow-cljs watch app` for live ClojureScript reloading
8. **Code formatting**: Use `bb format` to maintain consistent code style with cljstyle

## Build Process

The project uses tools.build for creating production artifacts:
- **Build script**: `build.clj` contains build tasks
- **Clean**: Removes target directory and artifacts
- **Prep**: Prepares dependencies and compiles ClojureScript
- **Uber**: Creates standalone JAR with all dependencies
- **All**: Runs complete build process (clean, prep, ClojureScript compile, uber)

## Common Development Tasks

### Adding a New API Endpoint
```clojure
;; In routes/api.clj
["/new-endpoint" {:get {:handler controllers.new/handle-get
                        :responses {200 {:body :map}}}}]

;; Create controllers/new.clj
(ns surprisebuild.surprisebuildweb2.web.controllers.new)

(defn handle-get [request]
  {:status 200
   :body {:message "Hello from new endpoint"}})
```

### Adding Environment Configuration
```clojure
;; In resources/system.edn
:new/component
{:config-value #or [#env NEW_CONFIG_VALUE "default-value"]}
```

### Running Tests
```bash
# Run all tests
make test

# Run specific test namespace
clj -M:test -n surprisebuild.surprisebuildweb2.test-namespace
```

This project provides a solid foundation for building Clojure web applications with modern tooling and best practices.
