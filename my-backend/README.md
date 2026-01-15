# Task Management API

A RESTful API backend built with NestJS, TypeORM, and PostgreSQL. This project demonstrates backend development skills including API design, database modeling, validation, and modular architecture.

## Tech Stack

| Technology | Purpose |
|------------|---------|
| **NestJS v11** | Backend framework with TypeScript |
| **TypeORM** | ORM for database operations |
| **PostgreSQL** | Relational database |
| **class-validator** | Request validation & DTO enforcement |
| **Jest** | Unit & E2E testing |

## Features

- Full CRUD operations for tasks and users
- Request validation with DTOs and class-validator
- Task status management (Pending, In Progress, Completed)
- Optional deadline tracking for tasks
- Auto-generated timestamps (createdAt, updatedAt)
- Modular architecture following NestJS best practices
- Environment-based configuration

## API Endpoints

### Tasks

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/tasks` | Get all tasks |
| `GET` | `/tasks/:id` | Get task by ID |
| `POST` | `/tasks` | Create new task |
| `PATCH` | `/tasks/:id` | Update task |
| `DELETE` | `/tasks/:id` | Delete task |

### Users

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/users` | Get all users |
| `GET` | `/users/:id` | Get user by ID |
| `POST` | `/users` | Create new user |

### Request/Response Examples

**Create Task:**
```json
POST /tasks
{
  "name": "Complete project",
  "description": "Finish the backend API",
  "status": "PENDING",
  "deadline": "2025-02-01T00:00:00.000Z"
}
```

**Response:**
```json
{
  "id": 1,
  "name": "Complete project",
  "description": "Finish the backend API",
  "status": "PENDING",
  "deadline": "2025-02-01T00:00:00.000Z",
  "createdAt": "2025-01-15T10:30:00.000Z",
  "updatedAt": "2025-01-15T10:30:00.000Z"
}
```

## Project Structure

```
src/
├── main.ts                 # Application entry point
├── app.module.ts           # Root module with TypeORM config
├── app.controller.ts       # Root controller
├── app.service.ts          # Root service
├── tasks/
│   ├── tasks.module.ts     # Tasks feature module
│   ├── tasks.controller.ts # Tasks endpoints
│   ├── tasks.service.ts    # Tasks business logic
│   ├── entities/
│   │   └── task.entity.ts  # Task database model
│   └── dto/
│       ├── create-task.dto.ts
│       └── update-task.dto.ts
└── users/
    ├── users.module.ts
    ├── users.controller.ts
    ├── users.service.ts
    ├── entities/
    │   └── user.entity.ts
    └── dto/
        ├── create-user.dto.ts
        └── update-user.dto.ts
```

## Database Schema

### Task Entity
| Column | Type | Description |
|--------|------|-------------|
| `id` | int | Primary key |
| `name` | varchar | Task name |
| `description` | text | Optional description |
| `status` | enum | PENDING, IN_PROGRESS, COMPLETED |
| `deadline` | timestamp | Optional deadline |
| `createdAt` | timestamp | Auto-generated |
| `updatedAt` | timestamp | Auto-updated |

### User Entity
| Column | Type | Description |
|--------|------|-------------|
| `id` | int | Primary key |
| `name` | varchar | User name |
| `email` | varchar | User email |

## Getting Started

### Prerequisites
- Node.js 18+
- PostgreSQL 14+

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/task-management-api.git
cd task-management-api
```

2. Install dependencies
```bash
npm install
```

3. Configure environment variables
```bash
cp .env.example .env
# Edit .env with your database credentials
```

4. Create PostgreSQL database
```bash
createdb tasks_db
```

5. Run the application
```bash
# Development
npm run start:dev

# Production
npm run build
npm run start:prod
```

The API will be available at `http://localhost:3000`

## Scripts

| Command | Description |
|---------|-------------|
| `npm run start:dev` | Development mode with hot reload |
| `npm run start:prod` | Production mode |
| `npm run build` | Build the application |
| `npm run test` | Run unit tests |
| `npm run test:e2e` | Run E2E tests |
| `npm run lint` | Run ESLint |

## iOS Client App

This backend powers a native iOS app built with SwiftUI. The mobile client demonstrates the full-stack integration.

<p align="center">
  <img src="screenshots/task_listing.png" width="250" alt="Task List Empty State"/>
  <img src="screenshots/create-task.png" width="250" alt="Create Task"/>
  <img src="screenshots/task_list-1.png" width="250" alt="Task List"/>
</p>

## License

MIT
