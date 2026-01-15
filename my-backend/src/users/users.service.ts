import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepo: Repository<User>,
  ) {}

  findAll() {
    return this.usersRepo.find();
  }

  findOne(id: number) {
    return this.usersRepo.findOne({ where: { id } });
  }

create(userData: { name: string; email: string }) {
  const user = this.usersRepo.create(userData);
  return this.usersRepo.save(user);
}


  remove(id: number) {
    return `This action removes a #${id} user`;
  }
}
