import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Task } from './entities/task.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';

@Injectable()
export class TasksService {
  constructor(
    @InjectRepository(Task)
    private tasksRepo: Repository<Task>,
  ) {}

  create(createTaskDto: CreateTaskDto) {
    const task = this.tasksRepo.create(createTaskDto);
    return this.tasksRepo.save(task);
  }

  findAll() {
    return this.tasksRepo.find();
  }

  async findOne(id: number) {
    const task = await this.tasksRepo.findOne({ where: { id } });
    if (!task) {
      throw new NotFoundException(`Task with ID ${id} not found`);
    }
    return task;
  }

  async update(id: number, updateTaskDto: UpdateTaskDto) {
    const task = await this.findOne(id);
    Object.assign(task, updateTaskDto);
    return this.tasksRepo.save(task);
  }

  async remove(id: number) {
    const task = await this.findOne(id);
    return this.tasksRepo.remove(task);
  }
}
